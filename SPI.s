#include <avr/io.h>

#include "SPI.inc.s"

.global SPI_Initialize
.func	SPI_Initialize
SPI_Initialize:

	in		r24, _SFR_IO_ADDR(PRR)
	andi	r24, ~_BV(PRUSI)
	out		_SFR_IO_ADDR(PRR), r24
	out		_SFR_IO_ADDR(USISR), r1
	out		_SFR_IO_ADDR(USICR), r1

	//SCK out
	sbi		_SFR_IO_ADDR(DDRB), SCK_BIT

	//SCK ‚Í high ‚É‚µ‚È‚¢‚Æ‚È‚ç‚È‚¢
	//(CS low ‘JˆÚŽž‚É high ‚Æ‚·‚é‚½‚ß)
	cbi		_SFR_IO_ADDR(PORTB), SCK_BIT

	//MISO out
	sbi		_SFR_IO_ADDR(DDRB), MISO_BIT

	//MOSI in/pullup
	cbi		_SFR_IO_ADDR(DDRB), MOSI_BIT
	sbi		_SFR_IO_ADDR(PORTB), MOSI_BIT

	//CS out/high
	sbi		_SFR_IO_ADDR(DDRB), CS_BIT
	sbi		_SFR_IO_ADDR(PORTB), CS_BIT

	ret
.endfunc

.global SPI_Uninitialize
.func	SPI_Uninitialize
SPI_Uninitialize:
	in		r24, _SFR_IO_ADDR(PRR)
	ori		r24, _BV(PRUSI)
	out		_SFR_IO_ADDR(PRR), r24

	in		r24, _SFR_IO_ADDR(DDRB)
	andi	r24, ~(_BV(PB0)|_BV(PB1)|_BV(PB2)|_BV(PB3));
	out		_SFR_IO_ADDR(DDRB), r24
	in		r24, _SFR_IO_ADDR(PORTB)
	ori		r24, _BV(PB0)|_BV(PB1)|_BV(PB2)|_BV(PB3);
	out		_SFR_IO_ADDR(PORTB), r24
	ret
.endfunc

.func	shiftUSI
shiftUSI:
	.rept	8
	out		_SFR_IO_ADDR(USICR), r18
	out		_SFR_IO_ADDR(USICR), r19
	.endr
	ret
.endfunc

.global SPI_ReadStart
.func	SPI_ReadStart
SPI_ReadStart:
	//CS  high
	sbi		_SFR_IO_ADDR(PORTB), CS_BIT

	//CS low
	cbi		_SFR_IO_ADDR(PORTB), CS_BIT

	ldi		r18, _BV(USIWM0) | _BV(USITC)
	ldi		r19, _BV(USIWM0) | _BV(USITC) | _BV(USICLK)

	//command
	ldi		r25, 0x03
	out		_SFR_IO_ADDR(USIDR), r25
	rcall	shiftUSI

	//A16-A23
	out		_SFR_IO_ADDR(USIDR), r24
	rcall	shiftUSI

	//A8-A15
	out		_SFR_IO_ADDR(USIDR), r23
	rcall	shiftUSI

	//A0-A7
	out		_SFR_IO_ADDR(USIDR), r22
	rjmp	shiftUSI

.endfunc	
	

.global SPI_ReadNext
.func	SPI_ReadNext
SPI_ReadNext:
	ldi		r18, _BV(USIWM0)|_BV(USITC)
	ldi		r19, _BV(USIWM0)|_BV(USITC)|_BV(USICLK)
	rcall	shiftUSI
	in		r24, _SFR_IO_ADDR(USIDR)
	ret
.endfunc

.global	SPI_ReadNextWord
.func	SPI_ReadNextWord
SPI_ReadNextWord:
	ldi		r18, _BV(USIWM0)|_BV(USITC)
	ldi		r19, _BV(USIWM0)|_BV(USITC)|_BV(USICLK)
	rcall	shiftUSI
	in		r24, _SFR_IO_ADDR(USIDR)
	rcall	shiftUSI
	in		r25, _SFR_IO_ADDR(USIDR)
	ret
.endfunc

.global SPI_ReadNextDoubleWord
.func	SPI_ReadNextDoubleWord
SPI_ReadNextDoubleWord:
	ldi		r18, _BV(USIWM0)|_BV(USITC)
	ldi		r19, _BV(USIWM0)|_BV(USITC)|_BV(USICLK)
	rcall	shiftUSI
	in		r22, _SFR_IO_ADDR(USIDR)
	rcall	shiftUSI
	in		r23, _SFR_IO_ADDR(USIDR)
	rcall	shiftUSI
	in		r24, _SFR_IO_ADDR(USIDR)
	rcall	shiftUSI
	in		r25, _SFR_IO_ADDR(USIDR)
	ret
.endfunc

.global SPI_ReadEnd
.func	SPI_ReadEnd
SPI_ReadEnd:
	sbi		_SFR_IO_ADDR(PORTB), CS_BIT
	ret
.endfunc

.global SPI_ReadId
.func	SPI_ReadId
SPI_ReadId:
	cbi		_SFR_IO_ADDR(PORTB), CS_BIT

	ldi		r18, _BV(USIWM0)|_BV(USITC)
	ldi		r19, _BV(USIWM0)|_BV(USITC)|_BV(USICLK)

	ldi		r24, 0x90
	out		_SFR_IO_ADDR(USIDR), r24
	rcall	shiftUSI

	clr		r24
	out		_SFR_IO_ADDR(USIDR), r24
	rcall	shiftUSI
	out		_SFR_IO_ADDR(USIDR), r24
	rcall	shiftUSI
	out		_SFR_IO_ADDR(USIDR), r24
	rcall	shiftUSI

	rcall	shiftUSI
	in		r25, _SFR_IO_ADDR(USIDR)

	rcall	shiftUSI
	in		r24, _SFR_IO_ADDR(USIDR)

	sbi		_SFR_IO_ADDR(PORTB), CS_BIT
	ret
.endfunc
