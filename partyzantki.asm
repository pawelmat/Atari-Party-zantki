; *********************************************
; Party-Zantki - 256b Atari XE/XL mini-demo
; Kane / Suspect
; Evening 1: Luton, UK, 10/7/2022. Evening 2: Niesiolowice, PL, 10/8/2022
; Copyright (C) 2022 Pawel Matusz. Distributed under the terms of the GNU GPL-3.0.
; Assemble using MADS
; 
; Silly Venture 2022 Summer Edition (12-14/08/2022) Atari 256-bytes compo entry
; *********************************************

start 	= $4000		; do not change as the DL list is assumed to be in $40H
buf		= $4400
scr		= $5000
width	= 40
heigth	= 56

col_fl	= $bb
col_p1	= $33
col_p2	= $66


	icl "Includes/registers.asm"
	icl "Includes/zeropage.asm"

	org	start

	ldx	#heigth+>scr-1	; create display list
dlcreate:
	jsr	dl_elem_add
	jsr	dl_elem_add
	dex
	cpx #>scr
	bpl	dlcreate
	
	lda	#<dl
	sta	SDLSTL
	lda #$40
	sta	SDLSTH
	lda #$c0
	sta GPRIOR		; 80: 9 cols (GTIA graphics 10) - 9 arbitrary colours | 40: 16 shades (GTIA graphics 9) - all shades of one background colour | C0: 16 cols (GTIA graphics 11 - all colours of the same luminance)

; main loop
mainloop:
	lda	#128
vsync:
	cmp	VCOUNT
	bne	vsync

	lda	#0			; colour
	sta	t9
	sta	t10
	jsr	pzDraw2

	lda	t1
	sta	pathLoop+1	; move buffer every frame
	adc	#width+30
	sta	bufVal+1 	; move buffer every frame
	inc	t1

	; add new floor tile and decide about up/down shift
	lda	t3
	cmp	t4
	bne	noYUpdate
	lda	RANDOM		; get new Y value
	and	#31
	sta	t3			; t3 = target Y
noYUpdate:
	bit	RANDOM
	bpl	yCont

	lda	t3			; tend t4 towards t3
	cmp	t4
	bmi	yLower
	inc	t4
	inc	t4
yLower:
	dec	t4

yCont:
	lda	t4
bufVal:
	sta	buf

	; draw floor
	ldx	#255
pathLoop:
	lda	buf
	clc
	adc	#>scr
	sta	pathSet1+2
	sta	pathSet2+2

	lda	#col_fl		; add new floor at x
pathSet2:
	sta	scr,x

	inx
	lda	#0			; remove old floor at x+1
pathSet1:
	sta	scr,x

	inc	pathLoop+1	; progress buffer to next location
	cpx	#width
	bne	pathLoop

	lda	#col_p1		; colour of character 1
	sta	t9
	lda	#col_p2		; colour of character 2
	sta	t10
	jsr	pzDraw2

	jmp mainloop

; -------------------------------------------
; t9 - col1, t10 - col2
pzDraw2:
	lda	t9			; colour
	sta	t7
	lda	#width/2-14
	sta	t8
	jsr	pzDraw		; draw partyzantka
	lda	t10			; colour
	sta	t7
	lda	#width/2+5
	sta	t8

; draw Partyzantka. In: t7 - colour, t8 - X pos
pzDraw:
	lda	t8
	sta	pzSet1+1	; set X pos
;	clc
	adc	t1
	tax
	lda	buf,x
;	clc				; optional
	adc	#>scr+1
	sta	pzSet1+2
	sta	AUDF1		; audio frequency

	ldy	#12-1
	sty COLOR4		; set luminescence
	sty	AUDC1		; audio volume

pzLine:
	lda	partyzantka,y
	sta	t6
	ldx	#7
	lda	t7			; colour
pzRow:
	asl	t6
	bcc	pzNoSet
pzSet1:
	sta	scr+width/2,x
pzNoSet:
	dex
	bne	pzRow

	inc	pzSet1+2
	dey
	bpl	pzLine

pzEnd:
	rts

partyzantka:
	.byte	%00010000
	.byte	%00111000
	.byte	%00111000
	.byte	%00010000
	.byte	%01111100
	.byte	%00010000
	.byte	%00111000
	.byte	%01111100
	.byte	%11111110
	.byte	%00101000
	.byte	%00101000
	.byte	%01101100

; add Display List element - one mode 15 line and one blank line
dl_elem_add:
	lda	#$4f
	jsr	s1
	txa
		
s1:	sta dl1			; for this to work, "dl" must start on an even address
	inc s1+1
	bne s2
	inc s1+2
s2:
	inc s1+1
	rts

 	;.align 2,0			; TBD - remove
	;.byte	$70, $4F, a(scr), 0, $4F, a(scr), 0, $41, a(dl)
dl:	.byte 	$70			; MUST be at even address
dl1:

endmain1:

	org	dl1+[2*4*heigth]
	
dl2	.byte	$41, a(dl)

endmain2:

	.print	"----------------------------"
	.print	"Start: ", start, " DL: ", endmain1, " End: ", endmain2, " (Len: ", endmain1-start+endmain2-dl2, ")"
	.print	"File:  ", endmain1-start+endmain2-dl2+10  ; this includes org markers etc.
	.print	"----------------------------"
	