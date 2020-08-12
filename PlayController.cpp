#include <stdlib.h>
#include <avr/io.h>
#include <util/delay.h>
#include "SPIStream.h"
#include "WaveInfo.h"
#include "WaveParser.h"
#include "SPI.h"
#include "Decoder.h"
#include "PlayController.h"

PlayController::PlayController()
 : _state(State_Stop)
 , _pDecoder(0)
{
}

PlayController::~PlayController()
{
	stopHardware();
	::Decoder_Delete(_pDecoder);
}

void PlayController::Sleep(void)
{
	stopHardware();
}

bool PlayController::Play(SPIStream* pStream, uint32_t offset)
{
	_state = State_Stop;
	if (_pDecoder != NULL)
	{
		::Decoder_Delete(_pDecoder);
		_pDecoder = NULL;
	}

	pStream->SetPosition(offset);
	WaveInfo waveInfo;
	if (!WaveParser::Parse(pStream, waveInfo))
	{
		return false;
	}			
	_pDecoder = ::Decoder_Create(waveInfo);
	if (_pDecoder == NULL)
	{
		return false;
	}

	_sampleCount = 	::Decoder_GetTotalSamples(_pDecoder);
	uint16_t clock = static_cast<uint32_t>(F_CPU + (waveInfo.samplesPerSec / 2)) / waveInfo.samplesPerSec;
	uint8_t value;
	uint8_t prescale;
	if (clock > 255)
	{
		value = (clock + 4) >> 3;
		prescale = _BV(CS01);
	}
	else
	{
		value = clock;
		prescale = _BV(CS00);
	}
	startHardware();
	OCR0A = value;
	TCCR0B = prescale;
	return true;
}

void PlayController::Stop()
{
	_state = State_Stop;
}

PlayController::State PlayController::GetState() const
{
	return _state;
}

void PlayController::Timer()
{
	switch (_state)
	{
	case State_Play:
		OCR1B = ((uint16_t)(::Decoder_Decode(_pDecoder) & 0xff00) >> 8) ^ 0x80;
		if (--_sampleCount == 0)
		{
			_state = State_End;
		}
		break;
	case State_End:
		if (OCR1B != 0)
		{
			OCR1B--;
		}
		else
		{
			stopHardware();
		}
		break;
	}
}

void PlayController::stopHardware()
{
	_state = State_Stop;
	PRR |= _BV(PRTIM1)|_BV(PRTIM0);

	DDRB &= ~_BV(PB4);

	TCCR1 = 0x00;
	GTCCR = 0x00;
	PLLCSR = 0x00;
	TCCR0A = 0x00;
	TCCR0B = 0x00;
	TIMSK &= ~_BV(OCIE0A);
}

void PlayController::startHardware()
{
	PRR &= ~(_BV(PRTIM1)|_BV(PRTIM0));

	//bit7: CTC1
	//bit6: PWM1A
	//bit5-4: COM1A (disabled)
	//bit3-0: prescale (PCK)
	TCCR1 = _BV(CS10);

	//bit7:
	//bit6: PWM1B
	//bit5-4: COM1B (OC1B/~OC1B enable)
	//bit3: force output compare 1B
	//bit2: force output compare 1A
	//bit1: PSR1
	//bit0:
	GTCCR = _BV(PWM1B) | _BV(COM1B1);


	//bit7: LSM
	//bit2: PCKE
	//bit1: PLLE
	//bit0: PLOCK
	PLLCSR = _BV(LSM) | _BV(PCKE) | _BV(PLLE) | _BV(PLOCK);

	_delay_us(100);

	while (!(PLLCSR & _BV(PLOCK)))
		;


	//bit7-6: COM0A
	//bit5-4: COM0B
	//bit3-2: none
	//bit1  : WGM01
	//bit0  : WGM00 (ctc mode)
	TCCR0A = _BV(WGM01);

	OCR1B = 0x80;

	TIMSK |= _BV(OCIE0A);

	//oc1b output
	DDRB |= _BV(PB4);
	_state = State_Play;
}
