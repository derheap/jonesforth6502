
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

Base	equ $80
IP	equ Base
W	equ Base+2
X	equ Base+4
PSP	equ $300	; Parameter stack
TOSL	equ PSP+1	; Top of stack
TOSH	equ PSP+2
SOSL	equ PSP+3	; 2nd of stack
SOSH	equ PSP+4

Init
	SEI
	; Clear PSP. PSP grows down
	LDX #$00
        LDA #00
LoopI   DEX
        TXA		;debug
	STA PSP,x
        CPX #$00
        BNE LoopI
        DEX
        TXS		;X=$FF. Init return stack
        CLI
        LDA #$FF
        STA $32		;inverse flag
        JSR $FC58
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
        
        MAC DEFWORD
        WORD LAST
LAST	SET *-2
	BYTE {2}+{3}
        DC.S {1}
        WORD DOCOL
        ENDM
        
; X register points to next free cell (MSB)
        
	DEFCODE "DROP",4,0
;@TODO Ignore wrap around?
DROP    INX
        INX
        NEXT
        
	DEFCODE "SWAP",4,0
SWAP	LDA PSP+1,x	; Reason for growing stacks down?
        STA X
        LDA PSP+2,x
        STA X+1
	NEXT
        
	DEFCODE "DUP",3,0
DUP	DEX		; new cell
        DEX
        LDA SOSL,x
        STA TOSL,x
        LDA SOSH,x
        STA TOSH,x
	NEXT
        
        DEFCODE "+",1,0
ADD	CLC
	LDA SOSL,x
        ADC TOSL,x
        STA SOSL,x
        LDA SOSH,x
        ADC TOSH,x
        STA SOSH,x
        INX
        INX
        NEXT
        ENDM
        
        
        ; LOTS MISSING
        
	DEFCODE "EXIT",4,0
EXIT	POPRSP
        JMP HALT
        NEXT
        
	DEFCODE "LIT",3,0
	;(IP)->Stack
LIT     DEX		; new cell
        DEX
        LDY #0
        LDA (IP),y
        STA TOSL,x
        INY
        LDA (IP),y
        STA TOSH,x
	; IP+2
        CLC
        LDA IP
        ADC #2
        STA IP
        LDA IP+1
        ADC #0
        STA IP+1
	NEXT
        
        ; lots missing
        
COUT	EQU $FDED
        
        DEFCODE "EMIT",4,0
EMIT	TXA
	PHA
	LDA TOSL,x
        AND #$7F
        ORA #$80
        JSR COUT
        PLA
        TAX
        DEX
        DEX
        NEXT
        ENDM
        
 	DEFWORD "FAKE",4,0  
FAKE	DC.W LIT, 23, LIT, 42, LIT, 512+8, SWAP, DUP
	DC.W LIT, 42, LIT, 8, ADD, EMIT
        DC.W EXIT
HALT	JMP HALT
        
TEST0	LDA #>(FAKE-2)
	STA IP+1
        LDA #<(FAKE-2)
        STA IP
	NEXT
