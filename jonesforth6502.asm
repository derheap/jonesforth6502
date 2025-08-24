
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
CURBUF	equ Base+6
BUFEND	equ Base+8

PSP	equ $300	; Parameter stack
TOS	equ PSP+1	; Top of stack
SOS	equ PSP+3	; 2nd of stack

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
        JSR $FC58	;HOME
        LDA #0
        STA CURBUF
        STA BUFEND
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
SWAP	LDA TOS,x	; Reason for growing stacks down?
        STA X
        LDA TOS+1,x
        STA X+1
        LDA SOS,X
        STA TOS,X
        LDA SOS+1,X
        STA TOS+1,X
        LDA X
        STA SOS,X
        LDA X+1
        STA SOS+1,X
	NEXT
        
	DEFCODE "DUP",3,0
DUP	DEX		; new cell
        DEX
        LDA SOS,x
        STA TOS,x
        LDA SOS+1,x
        STA TOS+1,x
	NEXT
        
        DEFCODE "+",1,0
ADD	CLC
	LDA SOS,x
        ADC TOS,x
        STA SOS,x
        LDA SOS+1,x
        ADC TOS+1,x
        STA SOS+1,x
        INX
        INX
        NEXT
        ENDM
        
        DEFCODE "-",1,0
SUB	SEC
	LDA SOS,X
        SBC TOS,X
        STA SOS,X
        LDA SOS+1,X
        SBC TOS+1,X
        STA SOS+1,X
        INX
        INX
        NEXT
        ENDM
        
MUL	DEFCODE "*",1,0
	LDA TOS,X
        STA $54
        LDA TOS+1,X
        STA $55
        LDA SOS,X
        STA $50
        LDA SOS+1,X
        STA $51
        LDA #0
        STA $52
        STA $53
        JSR $FB60
	NEXT
        
        
        ; LOTS MISSING
        
	DEFCODE "EXIT",4,0
EXIT	POPRSP
        JMP HALT
        NEXT
        
	DEFCODE "LIT",3,0
	;(IP)->Stack
LIT     DEX
	DEX
        LDY #0
        LDA (IP),y
        STA TOS,x
        INY
        LDA (IP),y
        STA TOS+1,x
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
EMIT	;TXA
	;PHA
	LDA TOS,x
        ;AND #$7F
        ;ORA #$80
        JSR COUT
        ;PLA
        ;TAX
        DEX
        DEX
        NEXT
        ENDM
        
 	DEFWORD "FAKE",4,0  
FAKE	;DC.W LIT, 23, LIT, 42, LIT, 512+8, SWAP, DUP
	;DC.W LIT, 42, LIT, 8, DUP, EMIT, ADD, LIT, 1, SUB
        ;DC.W EMIT
        DC.W LIT, 65
        DC.W LIT, 42
        DC.W SWAP, DUP, LIT, 128, ADD
        DC.W EMIT
        DC.W EXIT
HALT	JMP HALT
        
TEST0	LDA #>(FAKE-2)
	STA IP+1
        LDA #<(FAKE-2)
        STA IP
	NEXT
