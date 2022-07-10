; *********************************************
; Party-Zantki - 256b Atari mini-demo
; Kane / Suspect
; Luton, 10/7/2022
; Copyright (C) 2022 Pawel Matusz. Distributed under the terms of the GNU GPL-3.0.
; 
; Silly Venture 2022 Atari 256-bytes compo entry
; *********************************************

start 	= $4000
scr		= $5000
charset	= $e000+32*8
width	= 32		; narrow playfield
heigth	= 32
//heigth	= 56
sync	= 20

seccnt	= $90
letter	= $91
t1		= $92
stab    = $98


	icl "Includes/registers.asm"
	icl "Includes/zeropage.asm"

	org	start

	// create display list
	
	ldx	#heigth+>scr-1
dlcreate
	ldy #3
dlc1
	jsr	dl_elem_add
	dey
	bpl dlc1
	dex
	cpx #>scr
	bpl	dlcreate
	
	dec	SDMCTL		; $21 = narrow playfield
	lda	#<dl
	sta	SDLSTL
	lda #$40
	sta	SDLSTH
	sta GPRIOR

	ldx	#32
	ldy	#29		;27, 29, 30
	sty seccnt
ct1
	sty stab,x
	adc	#224	;192, 224, 240
	bcc	ct2
	dey
ct2
	dex
	bne	ct1

	// main loop
mainloop

	ldx	#4
syncloop
	dec	seccnt
	lda	seccnt
	and	#$f
vsync
	cmp	VCOUNT
	bne	vsync
	dex
	bne	syncloop

	lda	seccnt
	bpl	zoomer
	lda	#30
	sta seccnt

	ldx	letter
	lda text,x		;color, column
	inx
	ldy	text,x		; char
	inx
	cpx	#textend-text
	bne	nowrap
	ldx	#0
nowrap	
	stx	letter
	
	sty	printline+1
	tay
	and	#$0f
	asl
	sta scrptr1
	tya
	and #$f0
	sta COLOR4
	lda	#>scr+heigth/2-4
	sta	scrptr1+1

printchar
	ldy #7
printline			; print one font pixel line
	lda	charset,y
	ldx	#7
printdot			; print single font "pixel"
	lsr
	bcc	nodot
	pha
	lda	#$ff
scrptr1 = *+1
	sta scr,x
	pla
nodot
	dex
	bpl printdot
	inc scrptr1+1
	dey
	bpl printline
	bmi	mainloop

	.proc zoomer
	lda #>scr
	sta ptarget1+2
	lda	#heigth-1
	sta t1
pcollumn
	ldx t1
	lda stab,x
	adc #>scr
	tax
	stx	psource1+2
	stx	psource2+2
	inx
	stx	psource3+2
	dex
	dex
	stx	psource4+2
	ldx	#width-1
pline					; print one pixel line
	ldy stab,x
psource1
	lda	scr,y
	iny
psource2
	adc	scr,y
	dey
psource3
	adc	scr,y
	iny
psource4
	adc	scr,y
	lsr
	lsr
ptarget1
	sta scr,x
	dex
	bpl pline

	inc ptarget1+2			; move screen to next line

	dec t1
	bne pcollumn
	.endp
	
	jmp mainloop

// add Display List element - one mode 15 line and one blank line
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

text
	.byte $16, ["S"-32]*8, $36, ["U"-32]*8
	.byte $55, ["S"-32]*8, $A7, ["P"-32]*8, $94, ["E"-32]*8
	.byte $26, ["C"-32]*8, $B7, ["T"-32]*8
textend
	.byte 0
	
;	.align 2
dl	.byte 	$70		; has to be aligned to even address
dl1
	;.byte	$4F, a(scr), 0, $4F, a(scr), 0, $41, a(dl)
	;.byte	$4F, 0, a(scr), 0, ... $41, a(dl)
	
	//org	dl1+[2*4*heigth]
	org	dl1+[4*4*heigth]
	
dl2	.byte	$41, a(dl)
;	.byte $4B, $41, $4E, $45
	