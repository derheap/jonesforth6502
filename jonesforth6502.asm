
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
	SEI
	; Clear PSP. PSP grows down
	LDX #$FF
        TXA
LoopI   STA PSP,x
        CPX #$00
        DEX		;Wrap around
        BNE LoopI
        TXS		;X=$FF. Init return stack
        CLI
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
        
; X register points to next free cell (MSB)
        
DROP    DEFCODE "DROP",4,0
;@TODO Ignore wrap around?
        INX
        INX
        NEXT
        
SWAP	DEFCODE "SWAP",4,0
	LDA PSP+1,x	; Reason for growing stacks down?
        STA X
        LDA PSP+2,x
        STA X+1
	NEXT
        
DUP	DEFCODE "DUP",3,0
	DEX
        DEX
        LDA PSP+3
        STA PSP+1
        LDA PSP+4
        STA PSP+2
	NEXT
        
FAKE	DC.W FAKE+2, FAKE+4
HALT	JMP HALT
        
TEST0	LDA #>FAKE
	STA IP+1
        LDA #<FAKE
        STA IP
	NEXTM
