; *********************************************
; Party-Zantki - 256b Atari mini-demo
; Kane / Suspect
; Luton, 10/7/2022
; Copyright (C) 2022 Pawel Matusz. Distributed under the terms of the GNU GPL-3.0.
; 
; Silly Venture 2022 Atari 256-bytes compo entry
; *********************************************

start 	= $4000		; do not change as the DL list is assumed to be in $40H
buf		= $4400
scr		= $5000
charset	= $e000+32*8
;width	= 32		; narrow playfield
width	= 40
heigth	= 56
sync	= 20

seccnt	= $90
temp1	= $91

	icl "Includes/registers.asm"
	icl "Includes/zeropage.asm"

	org	start

	ldx	#heigth+>scr-1	; create display list
dlcreate
	jsr	dl_elem_add
	jsr	dl_elem_add
	dex
	cpx #>scr
	bpl	dlcreate
	
;	dec	SDMCTL		; $21 = narrow playfield
	lda	#<dl
	sta	SDLSTL
	lda #$40
	sta	SDLSTH
	sta GPRIOR
	sta RTCLOKM
	sta RTCLOKL

	// main loop
mainloop
	ldy	#sync
vsync
	cpy	VCOUNT
	bne	vsync

	lda	t1
	sta	pathLoop+1	; move buffer every frame
	adc	#width+30
	sta	bufVal+1 	; move buffer every frame
	inc	t1

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
	jmp	yCont
yLower:
	dec	t4

yCont:
	lda	t4
bufVal:
	sta	buf



	ldx	#255
pathLoop:
	lda	buf

	clc
	adc	#>scr
	sta	pathSet1+2
	sta	pathSet2+2

	lda	#$ff
pathSet2:
	sta	scr,x

	inx
	lda	#0
pathSet1:
	sta	scr,x

	inc	pathLoop+1	; progress buffer

	cpx	#width
	bne	pathLoop


	jmp mainloop

; add Display List element - one mode 15 line and one blank line
dl_elem_add
	lda	#$4f
	jsr	s1
	txa
		
s1	sta dl1			; for this to work, "dl" must start on an even address
	inc s1+1
	bne s2
	inc s1+2
s2	
	inc s1+1
	rts

	.align 2,0			; TBD - remove
	;.byte	$70, $4F, a(scr), 0, $4F, a(scr), 0, $41, a(dl)
dl	.byte 	$70
dl1

endmain1

	org	dl1+[2*4*heigth]
	
dl2	.byte	$41, a(dl)

endmain2

	.print	"----------------------------"
	.print	"Start: ", start, " DL: ", endmain1, " End: ", endmain2, " (Len: ", endmain1-start+endmain2-dl2, ")"
	.print	"File:  ", endmain1-start+endmain2-dl2+10
	.print	"----------------------------"
	