
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
        
        JMP TEST0
   
; NEXT
	MAC NEXTM
        ; IP -> W
        ; IP+2
        CLC
        LDA IP
        STA W
        ADC #2
        STA IP
        LDA IP+1
        STA W+1
        ADC #0
        STA IP+1
        ; (W) -> X
        LDY #0
        LDA (W),y
        STA X,y
        INY
        LDA (W),y
        STA X,y
        ; JMP (X)
        JMP (X)
        ENDM
; Helper  
        MAC PUSHRSP
        LDA IP
        PHA
        LDA IP+1
        PHA
        ENDM
        
        MAC POPRSP
        PLA
        STA IP+1
        PLA
        STA IP
        ENDM
        
; DOCOL

DOCOL	PUSHRSP
	CLC
	LDA W
        ADC #2
        STA IP
        LDA W+1
        STA IP+1
NEXTJ   NEXTM

	MAC NEXT
	JMP NEXTJ
        ENDM

LAST	SET 0

	MAC DEFCODE
        WORD LAST
LAST	SET *-2
        BYTE {2}+{3}
        DC.S {1}
        WORD *+2
        ENDM
        
DROP    DEFCODE "DROP",4,0
        DEX
        DEX
        NEXT
        
SWAP	DEFCODE "SWAP",4,0
	NEXT
        
FAKE	DC.W FAKE+2, FAKE+4
HALT	JMP HALT
        
TEST0	LDA #>FAKE
	STA IP+1
        LDA #<FAKE
        STA IP
	NEXTM
