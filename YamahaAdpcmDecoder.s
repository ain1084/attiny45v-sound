#include <avr/io.h>

#include "Decoder.inc.s"
#include "WaveInfo.inc.s"
#include "SPI.inc.s"

#define		_step		0
#define		_data		2
#define		_dataFlag	3
#define		_predicted	4
#define		_blockCount 6
#define		_blockSize	8
#define		_end			10

.section	.text

.func readNext_Static
readNext_Static:
	macro_SPI_ReadNext r24, r18, r19
	ret
.endfunc

.global		YamahaAdpcmDecoder_Create
.func		YamahaAdpcmDecoder_Create
YamahaAdpcmDecoder_Create:
	push	r28
	push	r29
	push	r24
	push	r25
	ldi		r24, _end + Decoder_Table_Size
	mov		r25, r1
	rcall	malloc
	movw	r30, r24
	ldi		r26, lo8(Decode)
	ldi		r27, hi8(Decode)
	lsr		r27
	ror		r26
	std		Z + Decoder_Table_Func_Decode + 0, r26
	std		Z + Decoder_Table_Func_Decode + 1, r27
	pop		r29
	pop		r28
	ldd		r26, Y + WaveInfo_blockAlign
	ldd		r27, Y + WaveInfo_blockAlign + 1
	subi	r26, 4
	sbc		r27, r1
	movw	r20, r26
	push	r24
	push	r25
	ldd		r22, Y + WaveInfo_blockCount
	ldd		r23, Y + WaveInfo_blockCount + 1
	ldd		r24, Y + WaveInfo_blockCount + 2
	ldd		r25, Y + WaveInfo_blockCount + 3
	rcall	Mul1632
	add		r22, r22
	adc		r23, r23
	adc		r24, r24
	adc		r25, r25
	std		Z + Decoder_Table_TotalSamples, r22
	std		Z + Decoder_Table_TotalSamples + 1, r23
	std		Z + Decoder_Table_TotalSamples + 2, r24
	std		Z + Decoder_Table_TotalSamples + 3, r25
	pop		r25
	pop		r24
	adiw	r30, Decoder_Table_Size
	std		Z + _blockSize, r20
	std		Z + _blockSize + 1, r21
	ldi		r18, 127
	std		Z + _step, r18
	std		Z + _step + 1, r1
	std		Z + _predicted, r1
	std		Z + _predicted + 1, r1
	ldi		r18, 0xf0
	std		Z + _dataFlag, r18
	ldi		r18, 1
	std		Z + _blockCount, r18
	std		Z + _blockCount + 1, r1
	pop		r29
	pop		r28
	ret
.endfunc



.func		Decode
Decode:
	movw	r30, r24
	ldd		r24, Z + _dataFlag
	swap	r24
	or		r24, r24
	std		Z + _dataFlag, r24
	brmi	2f

	macro_SPI_Init r18, r19
	ldd		r20, Z + _blockCount
	ldd		r21, Z + _blockCount + 1
	subi	r20, 1
	sbc		r21, r1
	brne	1f
	rcall	readNext_Static
	std		Z + _predicted, r24
	rcall	readNext_Static
	std		Z + _predicted + 1, r24
	rcall	readNext_Static
	std		Z + _step, r24
	rcall	readNext_Static
	std		Z + _step + 1, r24
	ldd		r20, Z + _blockSize
	ldd		r21, Z + _blockSize + 1
1:
	std		Z + _blockCount, r20
	std		Z + _blockCount + 1, r21
	macro_SPI_ReadNext r24, r18, r19
	std		Z + _data, r24
	rjmp	1f
2:
	ldd		r24, Z + _data
	swap	r24
1:
	ldd		r22, Z + _step
	ldd		r23, Z + _step + 1
	movw	r26, r22
	movw	r20, r22

	lsr		r27
	ror		r26
	lsr		r27
	ror		r26
	lsr		r27
	ror		r26				; diff = step >> 3

	sbrs	r24, 2
	rjmp	1f
	add		r26, r22
	adc		r27, r23
1:
	lsr		r23
	ror		r22
	sbrs	r24, 1
	rjmp	1f

	add		r26, r22
	adc		r27, r23
1:
	lsr		r23
	ror		r22
	sbrs	r24, 0
	rjmp	1f
	add		r26, r22
	adc		r27, r23
1:
	mov		r18, r24
	ldd		r24, Z + _predicted
	ldd		r25, Z + _predicted + 1
	sbrs	r18, 3
	rjmp	1f

	sub		r24, r26
	sbc		r25, r27
	brvc	2f
	mov		r24, r1
	ldi		r25, 0x80	
	rjmp	2f
1:
	add		r24, r26
	adc		r25, r27
	brvc	2f
	ldi		r24, 0xff
	ldi		r25, 0x7f
2:
	std		Z + _predicted, r24
	std		Z + _predicted + 1, r25

	ldi		r26, 230
	clr		r27
	andi	r18, 0b111
	breq	1f
	subi	r18, 4
	brcs	1f
	ldi		r26, 307 - 256
	ldi		r27, 1
	breq	1f
	ldi		r26, 409 - 256
	dec		r18
	breq	1f
	clr		r26
	ldi		r27, 2
	dec		r18
	breq	1f
	ldi		r26, 614 - 512
1:
	clr		r18
	clr		r19
	clr		r23
	clr		r22

	.rept	8
		ror		r26
		brcc	2f
		add		r18, r20
		adc		r19, r21
		adc		r23, r22
	2:
		add		r20, r20
		adc		r21, r21
		adc		r22, r22
	.endr

	ror		r27
	brcc	2f
	add		r18, r20
	adc		r19, r21
	adc		r23, r22
2:
	add		r20, r20
	adc		r21, r21
	adc		r22, r22
	ror		r27
	brcc	2f
	add		r18, r20
	adc		r19, r21
	adc		r23, r22
2:
	cpi		r19, 127
	cpc		r23, r1
	brcc	2f
	ldi		r19, 127
	rjmp	3f
2:
	cpi		r19, lo8(24576)
	ldi		r20, hi8(24576)
	cpc		r23, r20
	brcs	3f
	ldi		r19, lo8(24576)
	ldi		r23, hi8(24576)
3:
	std		Z + _step, r19
	std		Z + _step + 1, r23
	ret

.endfunc

