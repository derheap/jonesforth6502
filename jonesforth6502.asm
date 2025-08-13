
	processor 6502
	seg.u ZEROPAGE	; uninitialized zero-page variables
	org $0

	seg CODE
	org $803	; starting address

Start
	lda #$32
        sta $400
        jmp Start