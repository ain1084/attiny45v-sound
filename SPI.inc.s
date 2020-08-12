#define SCK_BIT		PB2
#define MISO_BIT	PB1
#define MOSI_BIT	PB0
#define CS_BIT		PB3

.macro macro_SPI_Init reg1, reg2
	ldi		\reg1, _BV(USIWM0)|_BV(USITC)
	ldi		\reg2, _BV(USIWM0)|_BV(USITC)|_BV(USICLK)
.endm

.macro macro_SPI_USIShift reg1, reg2
	.rept	8
		out		_SFR_IO_ADDR(USICR), \reg1
		out		_SFR_IO_ADDR(USICR), \reg2
	.endr
.endm	

.macro macro_SPI_Skip temp, reg1, reg2, count
	ldi		\temp, \count
9:
	macro_SPI_USIShift \reg1, \reg2
	dec		\temp
	brne	9b
.endm

.macro macro_SPI_ReadNext return, reg1, reg2
	macro_SPI_USIShift \reg1, \reg2
	in		\return, _SFR_IO_ADDR(USIDR)
.endm

