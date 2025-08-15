
	processor 6502
	seg.u ZEROPAGE	; uninitialized zero-page variables
	org $0

	seg CODE
	org $803	; starting address
        
;          Figure 5. Register Assignments
;
;            W     IP    PSP   RSP   UP     TOS 
;
;6502        Zpage Zpage X     SP    Zpage  memory  [KUN81]

Base	equ $50
IP	equ Base
W	equ Base+2
X	equ Base+4
PSP	equ $300

Init
	; Clear PSP
	LDX #$00
        TXA
LoopI   STA PSP,x
        INX
        CPX #$00
        BNE LoopI
Halt
        JMP Halt
        
	MAC NEXT
        ; IP -> W
        ; IP+2
        CLC
        LDA IP+1
        STA W+1
        ADC #2
        LDA IP
        STA W
        ADC #0
        STA IP
        ; (W) -> X
        LDY #0
        LDA (W),Y
        STA X,Y
        INY
        LDA (W),Y
        STA X,Y
        ; JMP (X)
        JMP (X)
        ENDM
        
TEST0	NEXT
