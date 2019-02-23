
;------------------------------------------------------------------------------------------
; NFORMAT.ASM
;
;       ASM code for printing *NUMBERS* in a given base (2-16)
;
; This code is pretty complex, but a good example of complex, understandable code that students
; should STUDY (that means READ AND KEEP RE-READING 'TIL A GLIMMER OF UNDERSTANDING OCCURS!) 
;
; After understanding, students should be able to modify code to do a few other things, 
; like... 
;       centered field output; 
;       right padding and/or left justified output;
;       leading zero's perhaps
;       user-specifiable fill character (instead of ' ')
;       Seperating commas/bars (i.e., "131,991,999" or "0000_0010_1000_1111")
; 
; And for the brave, after major reading of later MASM documentation
; on directive and features which improve/automate parameter passing,
; a good change is to use new-style MASM parameter handling in the
; FORMAT_NUMBER procedure.
;------------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------------
; Separately assembled module requires assembler directives to specify the model, cpu, etc
; but *does not* have a .STACK directive - its stack must be provided in another module

.MODEL SMALL            ; Assembler directive specifying the segment model for the generated code
.386                    ; Assembler directive limiting us to instructions supported by 80386 CPU



;------------------------------------------------------------------------------------------
; VERY COMPLEX ROUTINE... Convert AX to STRING, in A GIVEN BASE (2-16, not validated), 
; terminated with '$' for use with DOS print ASCII$ (AH=9) service, right justified,
; in a given width, left-padded with ' ' FILL CHARACTER...
;
; INPUT STACK ON ENTRY:
;       [BP+12] FIELD_WIDTH (Desired formatted string width. If output < FIELD_WIDTH, 
;                  conversion is RIGHT justified, left-padded with BLANKS
;       [BP+10] BASE (numeric radix, 2-16, NOT VALIDATED!)  
;       [BP+8]  NUMBER (number to convert)
;       [BP+6]  BUF_WIDTH (Max. buffer storage, in bytes)
;       [BP+4]  STRING_BUFFER (String storage buffer address)
;       [BP+2]  RETURN_ADDRESS
; SP--> [BP+0]  BP (see 1st two lines of the procedure)
;
; CALLING CONVENTION:
;       
;       FORMAT_NUMBER( DS:mem16 STRING_BUFFER, imm16 BUF_WIDTH, imm16 NUMBER, imm16 BASE, imm16 FIELD_WIDTH )
;               
;               Parameter passing (C-standard) order right-to-left
;               Parameter removed from stack BEFORE return (ASM/Pascal convention)
;              
; Example:
;       BUFFER: [ffffffdddd]
;               [0123456789]
;               Shown here is FIELD_WIDTH=10, with a 4 digit result right justified
;               Leftmost character always at BUFFER[0] (string
;
;
;       FORMAT_NUMBER( buffer, 10, 2937, 10, 6 );       // 2937 in base-10, 6 char field
;       buffer: [  2937$???]
;       index->  0123456789
;
;       FORMAT_NUMBER( buffer, 10, 0xFACE, 16, 3 );       // 2937 in base-10, 6 char field
;       buffer: [FACE$     ]            ; conversion > field width doesn't truncate
;       index->  0123456789
;

.CODE   ; FORMAT_NUMBER belong in .CODE segment

FORMAT_NUMBER   PROC

        PUSH    BP                      ; Standard "prologue" code needed to address 
        MOV     BP, SP                  ; function parameters passed on the stack
        ;SUB     BP, nnn                ; often followed by this to reserve nnn bytes
                                        ; for local variables
                                        

        ; To be really nice to the caller, PUSHA/PUSHF saves all used registers
        ; *AND* - perhaps more importantly - the flags at the moment of entry.
        PUSHA                           
        PUSHF

        
        ; (1) successive division to get digits, using base and pushing each digit on stack.
        
        ; digit_counter = 0
        ; save "end-of-digits" marker (-1) on the stack
        ; do {
        ;    digit_val = number % base;
        ;    number = number / base;
        ;    save (push) char_digit on stack
        ;    digit_counter++
        ; } while ( number != 0 );

        MOV     BX, 0                   ; BX = counter for number of digits
        MOV     AX, [BP+8]              ; AX = number
        MOV     CX, [BP+10]             ; CX = Base (of which only low byte CL is used)
        MOV     DX, 0FFFFh              ; Special marker (-1) that CAN'T be a digit
        PUSH    DX                      ; pushed onto stack to indicate "end of digits"
_DO:
        MOV     DX, 0                   ; DX:AX is DWORD, with DX=0 so only the number in AX of interest.
        DIV     CX                      ; dword/word division results are :  AX=quotient, DX=remainder
        PUSH    DX                      ; save remainder for later
        INC     BX                      ; Digit counter increment
        TEST    AX, AX
        JNZ     _DO                     ; while ( AX is non-zero )
_WHILE:
        
        ; (1a) Successive division conversion complete, all digits (in binary) are stacked
        ;      and BX exits loop as count of digits
        ;      From this, compute number of left-padding spaces that need to be output
        ;      before the digits.
        
        MOV     DI, [BP+4]              ; Get address of digit character string storage buffer into DI
        MOV     CX, [BP+12]             ; Get the FIELD_WIDTH
        SUB     CX, BX                  ; PaddingLen = (FIELD_WIDTH - numberDigits)
                                        ; CX = paddingLen = number of leading blanks needed
        JLE     DONE_LEFT_PADDING       ; If Padding is NEGATIVE, skip padding loop!                                        
        
        MOV     AL, ' '                 ; Keep BLANK in AL for fastest use
DO_LEFT_PADDING:
        JCXZ    DONE_LEFT_PADDING
        MOV     BYTE PTR DS:[DI], AL    ; Store a leading-blank to string buffer, *DI++ = ' ';
        INC     DI
        DEC     CX
        JMP     DO_LEFT_PADDING
DONE_LEFT_PADDING:                                        
        
        
        ; (2) Successive division continued: Retrieve stacked digits :-)
        ;
        
_WHILE_DIGITS:   
        POP     AX                      ; Retrieve digit from stack
        CMP     AX, 0FFFFh              ; ? Special marker 'end-of-digits'?
        JE      END_LOOP
        
        MOV     SI, AX                  ; To use digit as index for DIGITS array, must be in to index register
        ADD     SI, OFFSET _CS_HEX_DIGITS  ; Compute address of DIGITS[SI], i.e.,  &DIGITS[SI],
                                           ;       This explicit address compute is required because CS: override can't do CS:DIGITS[SI] 
        MOV     DL, CS:[SI]             ; Get CHARACTER for the digit. This is equivalent to array usage DL = _CS_HEX_DIGITS[AX]
        
        MOV     DS:[DI], DL             ; Store the 8-bit character to storage buffer
        INC     DI                      ; increment storage buffer address pointer
                                        ; this is equivalent to C/C++ pointer op:   *DI++ = DL
        JMP     _WHILE_DIGITS
END_LOOP:
        
        
        ; RIGHT_PADDING would go here....
        
        
        
        ; (3) Exit digit character loop, DI points PAST last digit character
        MOV     BYTE PTR DS:[DI], '$'   ; Terminate with '$' for use via DOS print ASCII$ string
        
        ; todo: Limit checks vs buffer width!!!


        POPF
        POPA
        
        POP     BP              ; revert PUSH BP
        RET     10              ; Explicit removal 10-bytes (5 WORD parameters) from stack AFTER return


        ; Weird usage: Put DATA in the CODE segment, which ensures we can get it even if DS is 
        ; changed by the caller to some other segment.
        _CS_HEX_DIGITS  DB "0123456789ABCDEF"                    ; Array[16] digits, '0' .. 'F'
                                                                 ; for usage as CS:_CS_HEX_DIGITS[0..15]

        
FORMAT_NUMBER   ENDP


END
; Ahh... a separately assembled ASM module ALSO must end... with END :-)
