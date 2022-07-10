; *******************************************
; Register definitions
; Kane / Suspect
; Copyright (C) 2021-2022 Pawel Matusz. Distributed under the terms of the GNU GPL-3.0.
; *******************************************


.ifndef REGISTERS_ASM
REGISTERS_ASM = "y"

SDMCTL	=	$022F	; Direct Memory Access Control
DMACTL	=	$D400

CHART	=	$02F3	; Character Control
CHACTL	=	$D401

SDLSTL	=	$0230	; Display List Pointer 
DLISTL	=	$D402
SDLSTH	=	$0231
DLISTH	=	$D403

HSCROL	=	$D404	; Horizontal Fine Scroll
VSCROL	=	$D405	; Vertical Fine Scroll
PMBASE	=	$D407	; Player/Missile Base Address
CHBAS	=	$02F4	; Character Set Base Address
CHBASE	=	$D409
WSYNC	=	$D40A	; Wait for Horizontal Sync
VCOUNT	=	$D40B	; Vertical Line Counter
NMIEN	=	$D40E	; Non-Maskable Interrupt (NMI) Enable
NMIRES	=	$D40F	; Non-Maskable Interrupt (NMI) Reset
NMIST	=	$D40F	; Non-Maskable Interrupt (NMI) Status

COLOR0	=	$02C4	; Color/luminance of Playfield 0
COLPF0	=	$D016
COLOR1	=	$02C5
COLPF1	=	$D017
COLOR2	=	$02C6
COLPF2	=	$D018
COLOR3	=	$02C7
COLPF3	=	$D019
COLOR4	=	$02C8	; Color/luminance of Playfield background
COLBK	=	$D01A
GPRIOR	=	$026F
PRIOR	=	$D01B
GRACTL	=	$D01D	; Graphics Control

RANDOM	=	$D20A

RTCLOKH	=	$12
RTCLOKM	=	$13
RTCLOKL	=	$14

.endif