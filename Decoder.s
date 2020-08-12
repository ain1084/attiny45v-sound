#include "Decoder.inc.s"
#include "WaveInfo.inc.s"

	.section	.text

.global Decoder_Create
.func	Decoder_Create
Decoder_Create:
	movw	r30, r24
	ldd		r18, Z + WaveInfo_formatTag
	ldd		r19, Z + WaveInfo_formatTag + 1
	ldi		r30, lo8(ImaAdpcmDecoder_Create)
	ldi		r31, hi8(ImaAdpcmDecoder_Create)
	cpi		r18, 0x11
	cpc		r19, r1
	breq	1f
	ldi		r30, lo8(YamahaAdpcmDecoder_Create)
	ldi		r31, hi8(YamahaAdpcmDecoder_Create)
	cpi		r18, 0x20
	cpc		r19, r1
	breq	1f
	clr		r24
	clr		r25
	ret
1:
	lsr		r31
	ror		r30
	ijmp
.endfunc

.global Decoder_Delete
.func	Decoder_Delete
Decoder_Delete:
	rjmp	free
.endfunc

.global Decoder_Decode
.func	Decoder_Decode
Decoder_Decode:
	mov		r30, r24
	ldd		r20, Z + Decoder_Table_Func_Decode
	ldd		r21, Z + Decoder_Table_Func_Decode + 1
	adiw	r30, Decoder_Table_Size
	movw	r24, r30
	movw	r30, r20
	ijmp
.endfunc

.global Decoder_GetTotalSamples
.func Decoder_GetTotalSamples
Decoder_GetTotalSamples:
	mov		r30, r24
	ldd		r22, Z + Decoder_Table_TotalSamples
	ldd		r23, Z + Decoder_Table_TotalSamples + 1
	ldd		r24, Z + Decoder_Table_TotalSamples + 2
	ldd		r25, Z + Decoder_Table_TotalSamples + 3
	ret
.endfunc
