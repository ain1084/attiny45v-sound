#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include "PlayController.h"
#include "SPI.h"
#include "SPIStream.h"

enum PinState
{
	PinState_Unknown,
	PinState_Low,
	PinState_High,
};

static PlayController g_player;
static SPIStream g_stream;
static PinState g_pinState;
static uint16_t g_randx;
static uint16_t g_prevNumber = -1;

static int rand(int div)
{
	g_randx = (g_randx << 2) + g_randx + 1;
	return g_randx % div;
}

ISR(TIMER0_COMPA_vect)
{
	g_player.Timer();
}

EMPTY_INTERRUPT(PCINT0_vect)

ISR(WDT_vect)
{
	++g_randx;
	MCUSR &= ~_BV(WDRF);
}

static void initializePinState()
{
	g_pinState = (PINB & _BV(PB5)) ? PinState_High : PinState_Low;
}

static PinState getPinState()
{
	bool pin1st = (PINB & _BV(PB5)) ? true : false;
	_delay_ms(10);
	bool pin2st = (PINB & _BV(PB5)) ? true : false;
	if (pin1st && pin2st)
	{
		return PinState_High;
	}
	if (!pin1st && !pin2st)
	{
		return PinState_Low;
	}
	return PinState_Unknown;
}

static bool getPinTrigger()
{
	PinState pinState = getPinState();
	bool result = false;
	if (pinState != PinState_Unknown)
	{
		if (g_pinState == PinState_Low)
		{
			if (pinState == PinState_High)
			{
				//pre = high, cur = low
				result = true;
			}
		}
		g_pinState = pinState;
 	}
	return result;
}

static uint16_t getEntryCount()
{
	uint16_t count = 0;
	for (;;)
	{
		::SPI_ReadStart(count << 4);
		if (::SPI_ReadNext() == 0xff)
		{
			break;
		}
		count++;
	}
	return count;
}

static uint32_t getEntryAddress(uint16_t count)
{
	::SPI_ReadStart(count * 16 + 8);
	uint32_t result = ::SPI_ReadNextDoubleWord();
	return result;
}
	
static void randomPlay()
{
	g_player.Stop();
	g_stream.Wakeup();
	uint16_t entryCount = getEntryCount();

	uint16_t number = rand(entryCount);
	if (number == g_prevNumber)
	{
		number = (number + 1) % entryCount;
	}
	g_prevNumber = number;
	uint32_t address = getEntryAddress(number);
	g_player.Play(&g_stream, address);
}

int main()
{
	_delay_ms(500 / 8);	// wait 1sec
	initializePinState();

	//pin-change interrupt
	PCMSK |= _BV(PCINT5);
	GIMSK |= _BV(PCIE);

	DDRB &= ~_BV(PB5);
	PORTB |= _BV(PB5);

	ACSR |= _BV(ACD);
	PRR |= _BV(PRADC)|_BV(PRTIM1)|_BV(PRTIM0)|_BV(PRUSI);
	MCUCR |= _BV(BODS)|_BV(SE);

	sei();

	// for test when debugWire
//	randomPlay();

	for (;;)
	{
		PlayController::State state = g_player.GetState();
		switch (state)
		{
		case PlayController::State_Play:
		case PlayController::State_End:
			sleep_mode();
			break;
		default:
			//enter power down mode
			g_player.Sleep();
			g_stream.Sleep();
			set_sleep_mode(SLEEP_MODE_PWR_DOWN);
			wdt_disable();
			sleep_mode();
			set_sleep_mode(SLEEP_MODE_IDLE);
			WDTCR = _BV(WDCE)|_BV(WDE);
			WDTCR = _BV(WDIE)|_BV(WDP2)|_BV(WDP0);	// 0.5sec
			break;
		}
		if (getPinTrigger())
		{
			randomPlay();
		}
	}
}
