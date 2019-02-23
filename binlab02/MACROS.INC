
;------------------------------------------------------------------------------------------
; MACROS.INC
;
;       MACROS to simplify calling FORMAT_NUMBER procedure.
;       Each macro passes the parameters - via the stack - necessary to achieve the 
;       desired formatting.
;
;       These are *MACROS* - they are like editor macros: When the macro name is used
;       (like PRINT_HEX_FORMAT, the first macro below), it is *replaced with the actual
;       text of the macro's body*.  This is called 'macro expansion' - the name expands
;       to the actual code or other items, that it names.
;
;       Macros are often used for commonly repeated sequences of ASM instructions, like
;       passing parameters to functions.  An advantage is that, if a change is needed, 
;       it can be made to the macro body, rather than everywhere the code would otherwise
;       have been duplicated.
;
;       Macros themselves can be fairly complex, allowing text parameters to be inserted
;       into the macro body, allowing flexible use.
;
;       You should read these macros and understand how they relate to passing parameters 
;       to the FORMAT_NUMBER procedure.
;
;------------------------------------------------------------------------------------------

pushcontext all

.NOLIST
.386    ; macros require 80286 instruction set for push imm16



;--------- Macro to assist in printing hex digits:-)
PRINT_HEX_FORMAT MACRO buffer, number, field_width, endline
.NOLIST
        PUSHA
        PUSH    field_width     ; field width 8 digits
        PUSH    16              ; BASE=16 for hex_format
        PUSH    number          ; push the number
        PUSH    SIZE buffer     ; push maximum size of buffer
        PUSH    OFFSET buffer   ; push address of buffer
        
        CALL    FORMAT_NUMBER
        
        MOV     DX, OFFSET buffer
        MOV     AH, 9
        INT     21H
        
        IFNB <endline>
                MOV     AH, 9
                MOV     DX, OFFSET endline
                INT     21h
        endif
        POPA
.LIST
ENDM

PRINT_DEC_FORMAT MACRO buffer, number, field_width, endline
.NOLIST
        PUSHA
        PUSH    field_width     ; field width variant
        PUSH    10              ; BASE=10 for decimal
        PUSH    number          ; push the number
        PUSH    SIZE buffer     ; push maximum size of buffer
        PUSH    OFFSET buffer   ; push address of buffer
        CALL    FORMAT_NUMBER
        
        MOV     DX, OFFSET buffer
        MOV     AH, 9
        INT     21H
        
        IFNB <endline>
                MOV     AH, 9
                MOV     DX, OFFSET endline
                INT     21h
        endif
        POPA       
.LIST
ENDM


PRINT_BIN_FORMAT MACRO buffer, number, field_width, endline
.NOLIST
        PUSHA
        PUSH    field_width     ; field width variant
        PUSH    2               ; BASE=2 for binary format
        PUSH    number          ; push the number
        PUSH    SIZE buffer     ; push maximum size of buffer
        PUSH    OFFSET buffer   ; push address of buffer
        CALL    FORMAT_NUMBER
        
        MOV     DX, OFFSET buffer
        MOV     AH, 9
        INT     21H
        
        IFNB <endline>
                MOV     AH, 9
                MOV     DX, OFFSET endline
                INT     21h
        endif
        POPA
.LIST
ENDM

.LIST
popcontext all
