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
heigth	= 56
sync	= 20

seccnt	= $90
temp1	= $91

	icl "Includes/registers.asm"
	icl "Includes/zeropage.asm"

	org	start

	// create display list
	ldx	#heigth+>scr-1
dlcreate
	jsr	dl_elem_add
	jsr	dl_elem_add
	dex
	cpx #>scr
	bpl	dlcreate
	
	dec	SDMCTL		; $21 = narrow playfield
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

	lda RTCLOKM		; move increment time counter approx every second
	and	#$0f
	sta seccnt
	inc	RTCLOKL		; speed up clock ticks

	ldx	#0
eventcheck
	lda text,x		; valid time: from
	inx
	cmp	seccnt		; A-mem
	bpl	e1
	lda text,x		; valid time: to
	inx
	cmp	seccnt
	bmi	e2
	
	// print char
	lda text,x		;color, column
	inx
	ldy	text,x		; char
	stx	temp1
	
	sty	printline+1
	tay
	and	#$0f
	asl
	sta scrptr1
	tya
	and #$f0
	sta COLOR4
	lda	#>scr
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
	
	ldx temp1
	bne	e3
e1	inx
e2	inx
e3	inx
	cpx	#textend-text
	bmi	eventcheck

	.proc fire		; overlay the fire effect on the screen
	ldy	#heigth+>scr-1
fire1
	sty f1+2
	sty f5+2
	iny
	sty f6+2
	dey
	dey
	sty f2+2
	sty f3+2
	sty f4+2
	ldx #width-2
fire2				; average of 4 neighbours
f1	lda	scr,x
	inx
f2	adc scr+$100,x
	dex
f3	adc scr+$100,x
	dex
f4	adc scr+$100,x
	lsr
	lsr

	inx
f5	sta	scr,x

;	bit RTCLOKL
;	beq	f7
	bit RANDOM
	bpl	f7
;	bne	f7
f6	sta	scr,x
f7
	dex
	bne	fire2
	cpy #>scr
	bne	fire1
	.endp			; end of fire
	
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
	.byte $00, $03, $13, ["S"-32]*8, $01, $04, $19, ["V"-32]*8
	.byte $05, $0A, $52, ["R"-32]*8, $06, $0B, $AA, ["Z"-32]*8, $07, $0C, $96, ["L"-32]*8, $0C, $0E, $06, [63-32]*8
textend

dl	.byte 	$70
;	.align 2,0
dl1
	;.byte	$4F, a(scr), 0, $4F, a(scr), 0, $41, a(dl)
	
	org	dl1+[2*4*heigth]
	
dl2	.byte	$41, a(dl)
;	.byte $4B, $41, $4E, $45

	