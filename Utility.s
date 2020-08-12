
	; Mult1632(uint32_t, uint16_t)
	; r25:r24:r23:r22 = r25:r24:r23:r22 * r21:r20

.global Mul1632
.func	Mul1632
Mul1632:
	push	r16
	push	r17
	push	r18
	push	r19
	push	r26
	push	r20
	push	r21

	movw	r16, r22
	movw	r18, r24

	clr		r22
	clr		r23
	clr		r24
	clr		r25

	ldi		r26, 16
2:
	lsr		r21
	ror		r20
	brcc	1f
	add		r22, r16
	adc		r23, r17
	adc		r24, r18
	adc		r25, r19
1:
	add		r16, r16
	adc		r17, r17
	adc		r18, r18
	adc		r19, r19
	dec		r26
	brne	2b

	pop		r21
	pop		r20
	pop		r26
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	ret

.endfunc
