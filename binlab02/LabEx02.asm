;
; Binary debugging lab
;
; Pair Up.  
; Assemble this short ASM source to an executable, then load
; and TRACE through its machine code using the SYMDEB debugger.
;
; I suggest you keep this source up on one screen, with the
; debugger (in the DOS virtual machine).  While TRACING the 
; machine language in the debugger, FOLLOW ALONG in the 
; source code.
;
; As you do so, follow the instructions and make a table of
; the values you observed in the debugger.
;


.MODEL SMALL            ; Assembler directive specifying the segment model for the generated code
.386                    ; Assembler directive limiting us to instructions supported by 80386 CPU


;----- .STACK directive tells MASM to reserve 1024 bytes for the "stack" segment -----
;      (which we're not using explicitly, but is a VERY important!)
.STACK 1024             ; Setup 1K byte stack segment



.DATA

; String variable to print newline, i.e., cout << endl; or system.out.println("")
CRLF            DB      13, 10, '$'             

; String variables pre-formatted to print heading of table
HEADING         DB      "EXPONENT | 2^EXP (decimal) | 2^EXP (hex) | 2^EXP (binary) | OF | CF |", 13, 10, '$'
SEP_LINE        DB      "---------------------------------------------------------------------", 13, 10, '$'
                       ;"    9    |        17       |     13      |       16       |  4 |  4 |


; String variables to print CARRY and OVERFLOW flag states in the table 
; Note each is pre-formatted to 5-char width to match heading above
NC_STR          DB      "  NC ", '$'
CY_STR          DB      "  CY ", '$'
NV_STR          DB      "  NV ", '$'
OV_STR          DB      "  OV ", '$'

; String variable to store numbers converted to string format for printing
DIGIT_BUFFER    DB      32 DUP ( ' ' )
               


;------------------------------------------------------------------------------------------------
; *** NUMBER PRINTING MACRO SUPPORT ***
;------------------------------------------------------------------------------------------------
INCLUDE MACROS.INC



;----- .CODE directive tells MASM the following source is part of a "code" segment -----
.CODE

EXTRN   FORMAT_NUMBER:NEAR              ; Declare that there is an external NEAR procedure 
                                        ; named FORMAT_NUMBER


MAIN    PROC
        .STARTUP

         
        ;-----------------------------------------------------------------------------       
        ; Ok... Some simple assembly language to explore binary numbers...
        ; An exercise in 
        ;    1. Binary/Hex/Decimal numbers, particularly powers-of-TWO
        ;    2. Debugging and Tracing code in the SYMDEB debugger
        ;    3. Understanding more complicated ASM code
        
        
        
        ; Initialize AX and CX make a simple loop
        ; that performs this simple (psuedocode) experiment:
        
        ;       CX = 0;
        ;       AX = 2^CX;      // AX = 2^0 = 1
        ;       while ( CX < 16 )
        ;          NOP  // stopping point to write down CX (decimal), AX (decimal), AX (hexidecimal), AX (binary)
        ;          CX++;     
        ;          AX = 2^CX;       // Actual ASM code simply doubles AX, which achieves same result cheaply
        ;       end while
        ;
        
        ; The loop will give us the results, printing in the following format
        ;
        ;
        ;     EXPONENT (CX) |   AX  (decimal) | AX   (hex) | AX = 2^CX (binary)  | OF | CF |
        ;     -----------------------------------------------------------------------------+
        ;           0                1            0001          0000000000000001   NV   NC   
        ;           1                2            0002          0000000000000010   ??   ??  
        ;         . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
        ;          15              ?????          ????          ????????????????
        ; 

        CALL    PRINT_HEADER

        MOV     BX, 0                   ; We need to clear CF and OV on each iteration of the loop, so (0+0) does the trick
        MOV     CX, 0                   ; CX = exponent
        MOV     AX, 1                   ; AX = 2^CX = 2^0 == 1
              
        CALL    PRINT_ROW               ; print the starting conditions.              
      
AGAIN:  
        ADD     BX, BX                  ; (0+0) clears OV and CY flags to NV/NC

        INC     CX                      ; increment exponent
        ADD     AX,AX                   ; AX = 2^CX via doubling

        NOP                             ; STOP DEBUGGER HERE.
        CALL    PRINT_ROW
				        
        CMP     CX, 10h                 ; If CX < 16, do next iteration
        JL      AGAIN


                                                               
        MOV     AH, 9
        MOV     DX, OFFSET CRLF
        INT     21h

        
        
        .EXIT           
MAIN    ENDP




;---------------------------------------------------------------------------------------
; Special purpose, prints formatted table heading and separator
;
;HEADING         DB      "EXPONENT | 2^EXP (decimal) | 2^EXP (hex) | 2^EXP (binary) | OF | CF |", 13, 10, '$'
;SEP_LINE        DB      "---------------------------------------------------------------------", 13, 10, '$'
;                        ;    9    |        17       |     13      |       16       |  4 |  4 |

PRINT_HEADER    PROC
        
        MOV     DX, OFFSET HEADING
        MOV     AH, 9
        INT     21h
        
        MOV     DX, OFFSET SEP_LINE
        MOV     AH, 9
        INT     21h
        
        RET
PRINT_HEADER    ENDP


;--------------------------------------------------------------------------------------
; Total Special Purpose print routine to print each row of the table
; INPUT:  CX=exponent, AX=2^CX, FLAGS (as is)
; OUTPUT: Prints one row of table in the standard format:
        ;HEADING         DB      "EXPONENT | 2^EXP (decimal) | 2^EXP (hex) | 2^EXP (binary) | OF | CF |", 13, 10, '$'
        ;SEP_LINE        DB      "---------------------------------------------------------------------", 13, 10, '$'
        ;                        ;    9    |        17       |     13      |       16       |  4 |  4 |

PRINT_ROW       PROC
           
        PUSHA
                                     
        PUSHF           ; save *two* copies of the current flags 
        PUSHF           ; so we can print both carry & overflow without being disturbed by the actual printing.
        
        PRINT_DEC_FORMAT DIGIT_BUFFER, CX, 9
        PRINT_DEC_FORMAT DIGIT_BUFFER, AX, 18
        PRINT_HEX_FORMAT DIGIT_BUFFER, AX, 14
        PRINT_BIN_FORMAT DIGIT_BUFFER, AX, 17    ;NOTE: The 'CRLF' parameter
        
        
        ; print flags HERE
        ;NC_STR          DB      "  NC ", '$'
        ;CY_STR          DB      "  CY ", '$'
        ;NV_STR          DB      "  NV ", '$'
        ;OV_STR          DB      "  OV ", '$'

        POPF                            ; retrieve actual flags from last 2^CX operation
        ;TODO: print overflow flag here

        MOV DX, Offset NV_STR
        JNO OVPRINT
        MOV DX, Offset OV_STR
OVPRINT:
        MOV AH,9
        INT 21h

        
        POPF                            ; retrieve actual flags from last 2^CX operation
        ;TODO: Print carry flag here
        
        
        MOV DX, Offset NC_STR
        JNC NCPRINT
        MOV DX, Offset CY_STR
NCPRINT:
        MOV AH,9
        INT 21h


        MOV AH,9
        MOV DX, Offset CRLF
        INT 21h
        
        POPA
                   
        RET
PRINT_ROW       ENDP


; ---------- DON'T FORGET THE END AT... the end.  Seriously ----------
END




