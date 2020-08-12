#include <avr/io.h>

#include "SPI.inc.s"
#include "Decoder.inc.s"
#include "WaveInfo.inc.s"

#define		_stepIndex	0
#define		_data		1
#define		_dataFlag	2
#define		_predicted	3
#define		_blockCount 5
#define		_blockSize	7
#define		_end		9

.section	.text

indexTable:
	.byte	-1, -1, -1, -1, 2, 4, 6, 8

	.balign	2

stepTable:
	.word	    7,	  8,	9,	 10,   11,	 12,   13,	 14
	.word	   16,	 17,   19,	 21,   23,	 25,   28,	 31
	.word	   34,	 37,   41,	 45,   50,	 55,   60,	 66
	.word	   73,	 80,   88,	 97,  107,	118,  130,	143
	.word	  157,	173,  190,	209,  230,	253,  279,	307
	.word	  337,	371,  408,	449,  494,	544,  598,	658
	.word	  724,	796,  876,	963, 1060, 1166, 1282, 1411
	.word	 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024
	.word 	 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484
	.word 	 7132, 7845, 8630, 9493,10442,11487,12635,13899
	.word 	15289,16818,18500,20350,22385,24623,27086,29794
	.word	32767

.section	.text

.func readNext_Static
readNext_Static:
	macro_SPI_ReadNext r24, r18, r19
	ret
.endfunc

.global		ImaAdpcmDecoder_Create
.func		ImaAdpcmDecoder_Create
ImaAdpcmDecoder_Create:
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
	std		Z + _blockSize, r26
	std		Z + _blockSize + 1, r27
	std		Z + _stepIndex, r1
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
	std		Z + _stepIndex, r24
	rcall	readNext_Static			; dummy (always 0)
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
	mov		r20, r24			; r20 = adpcm data
	ldd		r21, Z + _stepIndex

	movw	r18, r30			; save Z

	; read step value
	ldi		ZL, lo8(stepTable)
	ldi		ZH, hi8(stepTable)
	mov		r22, r21
	add		r22, r22				; to word align
	add		ZL, r22
	adc		ZH, r1
	lpm		r22, Z+				; r22 = step
	lpm		r23, Z

	; calc stepIndex value
	ldi		ZL, lo8(indexTable)
	ldi		ZH, hi8(indexTable)
	andi	r24, 0b00000111	
	add		ZL,	r24				; adpcm & 0b111
	adc		ZH, r1
	lpm		r24, Z
	add		r24, r21
	brmi	1f
	cpi		r24, 88
	brlo	2f
	ldi		r24, 88
	rjmp	2f
1:
	clr		r24
2:
	movw	r30, r18			; restore Z
	std		Z + _stepIndex, 24

	movw	r26, r22
	lsr		r27
	ror		r26
	lsr		r27
	ror		r26
	lsr		r27
	ror		r26				; diff = step >> 3

	sbrs	r20, 2
	rjmp	1f
	add		r26, r22
	adc		r27, r23
1:
	lsr		r23
	ror		r22
	sbrs	r20, 1
	rjmp	1f

	add		r26, r22
	adc		r27, r23
1:
	lsr		r23
	ror		r22
	sbrs	r20, 0
	rjmp	1f
	add		r26, r22
	adc		r27, r23
1:
	ldd		r24, Z + _predicted
	ldd		r25, Z + _predicted + 1
	sbrs	r20, 3
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
	ret

.endfunc

