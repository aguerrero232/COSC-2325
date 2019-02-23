; Author Ariel Guerrero
; MIDTERM

.MODEL SMALL    

.386     

;----------------------------------------------------------------------------
; S T A C K 
;----------------------------------------------------------------------------
.STACK 4096     

;----------------------------------------------------------------------------
; D A T A
;----------------------------------------------------------------------------
.DATA           

CRLF         DB   13,10 ,"$"


mString    DB  "M",0
maString   DB  "Ma",0
manString  DB  "Man",0
longString DB "Man is distinguished, not only by his reason, "
         DB "but by this singular passion from other animals, "
         DB "which is a lust of the mind, "
         DB "that by a perseverance of delight in the continued "
         DB "and indefatigable generation of knowledge, "
         DB "exceeds the short vehemence of any carnal pleasure.",0
        

cmdString    DB  256 dup(0),0
destString   DB  512 dup(0),0




;----------------------------------------------------------------------------
; C O D E  S E G M E N T 
;----------------------------------------------------------------------------
.CODE           
;----------------------------------------------------------------------------------------




; Function: CRLF
;
;       makes a new line     
;
; INPUT:
;    
;               CRLF from data we do this because we dont want to mess with the stack    
;
; OUTPUT:
;
;                 new lines printed
;
;-----------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------
CRLFPRNT PROC
PUSH AX

MOV AH,9
MOV DX, OFFSET CRLF
INT 21H

POP AX
RET
CRLFPRNT ENDP



; Function: base64Encode
;
;    Encodes given string parameter (clearText) into base64 with '=' padding
;
; INPUT:
;    
;    clearText      CHAR PTR to zstring parameter containing *ASCII-ONLY* text.  
;                   It would be possible to encode unicode or other char-encodings 
;                   but I don't want to make this TOO difficult 
; OUTPUT:
;    returnstring   The string return value is the encoded form of the clearText parameter,
;                   padded with the base64 standard padding character, ASCII '=' (0x3D or 61)
;                   This padding ensures output can be concatenated with other base64
;                   strings and is required in most cases.
;
;-----------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------

Base64Encode PROC   

; possible use of the CX REGISTER as a counter to compare to 

; *** heres where we set the base pointer for the stack! ***

PUSH    BP              ; Standard "prologue" code needed to address 
MOV     BP, SP          ; function parameters passed on the stack

MOV     SI,[BP+4] ; has all the source chars we want to encode 
    
PUSH    SI
CALL    COUNTZ
ADD     SP,2

MOV     CX, AX   ; Moves the integer length of the source string from AX to CX  
MOV     AX,0     ; reset AX
NOP              ; checking here 

MOV     DI, [BP+6] ; has the destString buffer to store our encoded chars


DEFAULT:

; need a check to test if its an empty string
CMP CX,0
JE  DONE

; need a check to see if its 3 chars and of not how many......

;------------------------------------------------------------------------------------------------------------    
; HIGH LEVEL + PSUDEO FOR 1ST CHAR
;------------------------------------------------------------------------------------------------------------    
    ;     ixDigit[0] = (clearText[0] >> 2);            // (uuuu_vvVV SHR 2) == 00uu_uuvv 
    ;                                                 // Gives our 1st base64 digit:: uuuuvv
    ; compute decodeIndex[0]
;------------------------------------------------------------------------------------------------------------    
; ACTUAL 
;------------------------------------------------------------------------------------------------------------    
    MOV     BX, 0
    MOV     AL,[SI]     ;1st char   clearText[0]
    ; AL has an ascii a bit char we only want the first 6 bits
    SHR     AL, 2 ; e x) abcd efgh -> 00ab cdef
    MOV     BL, AL
    MOV     AH, 0
    MOV     AL, CS:b64Table[BX]
    MOV     [DI], AL ; dst string decodeIndex[0] 
    NOP

 

;------------------------------------------------------------------------------------------------------------    
; HIGH LEVEL + PSUDEO FOR 2ND CHAR
;------------------------------------------------------------------------------------------------------------    
    ;
    ;     ixDigit[1] = ((clearText[0] & 0x03) << 4)    // ((uuuu_VVvv & 0000_0011) SHL 4) == 00vv_0000
    ;              |                               //  BINARY OR with...
    ;               (clearText[1] >> 4);            // (wwww_xxxx SHR 4) == 0000_wwww
    ;                                                // 00vv_0000|0000_wwww == 00vv_wwww 
    ;                                                 // Gives our 2nd base64 digit: vvwwww
    ;
    ; compute decodeIndex[1]
    ;  AL has 1st char        MOV AL,[SI]   
    ;2nd char   clearText[1]  ALSO uses SI+1
    ;  using top example: abcd efgh   need the last 2 so shift left four 
    ;  SHL AL,4
    ;                                                                        efgh 0000
    ;  AND AL,3F                                                             0011 1111
    ;                                                              result->  00gh 0000
    ;  MOV AH,[SI+1] -> ijkl mnop 
    ;   we want 00gh+ijkl
    ;    SHR AH,4   ->  0000 ijkl
    ; now compsine them using or 
    ;    OR AL,AH                                               00gh 0000
    ;                                                           0000 ijkl
    ;                                                           00gh ijkl
    ;
    ; now need to store this value                                                          
;------------------------------------------------------------------------------------------------------------    
; ACTUAL
;------------------------------------------------------------------------------------------------------------    
    MOV     BX, 0
    MOV     AL,[SI] 
    SHL     AL,4
    AND     AL,3F
    MOV     AH,[SI+1]
    SHR     AH, 4
    OR      AL,AH
    MOV     BL, AL
    MOV     AH,0
    MOV     AL, CS:b64Table[BX]
    MOV     [DI+1], AL ; dst string decodeIndex[1] 
    NOP

    CMP  CX,2
    JE   _2CHAR

;------------------------------------------------------------------------------------------------------------ 
; HIGH LEVEL + PSUDEO FOR 3RD CHAR  
;------------------------------------------------------------------------------------------------------------    
    ;     ixDigit[2] = ((clearText[1] & 0x0F) << 2)   // ((wwww_xxxx & 0000_1111) SHL 2) == 00xx_xx00
    ;               |                                 //  BINARY OR with...
    ;                 (clearText[2] >> 6);            // (yyYY_zzzz SHR 6) == 0000_00yy 
    ;                                                 // 00xx_xx00|0000_00yy == 00xx_xxyy 
    ;                                                 // Gives our 3rd base64 digit: xxxxyy
    ;
    ;   the 3rd char uses clearText[1] and cleaarText[2]
    ;   clearText[1] = ijkl mnop need -> 00mn op00 
    ;         shift left 2
    ;  SHL
    ; compute decodeIndex[2]
;------------------------------------------------------------------------------------------------------------
; ACTUAL    
;------------------------------------------------------------------------------------------------------------      

    MOV     BX, 0
    MOV     AL,[SI+1]   ;   clearText[2]
    SHL     AL, 2
    AND     AL,15
    MOV     AH, [SI+2]
    SHR     AH,6
    OR      AL,AH
    MOV     BL, AL
    MOV     AH,0
    MOV     AL, CS:b64Table[BX]
    MOV     [DI+2], AL ; dst string decodeIndex[2] 
    NOP
;------------------------------------------------------------------------------------------------------------
; HIGH LEVEL + PSUDEO FOR 4TH CHAR 
;------------------------------------------------------------------------------------------------------------       
    ;
    ;     ixDigit[3] = (clearText[2] & 0x3F);          // AND finally, yyyy_zzzz & 0011_1111 == 00yy_zzzz
    ;                                                   // Gives our 4th base64 digit: yyzzzz
    ; compute decodeIndex[3]
;------------------------------------------------------------------------------------------------------------    
; ACTUAL 
;------------------------------------------------------------------------------------------------------------    
    MOV     BX, 0
    MOV     AL, [SI+2] 
    SHL     AL, 2   ; just want the last 6 so move abcd efgh left 2  -> cdef gh00   
    SHR     AL, 2   ;                now move back for correct value -> 00cd efgh 
    MOV     BL, AL
    MOV     AH, 0 
    MOV     AL, CS:b64Table[BX]
    MOV     [DI+3], AL ; dst string decodeIndex[3] 
    NOP             ; DI++ DI IS NOW 4 

    CMP  CX,1
    JE   _1CHAR
;------------------------------------------------------------------------------------------------------------    
; 
;------------------------------------------------------------------------------------------------------------    
    
    ; next 3 in next 4 out because for every 3 you get four
    ADD    SI,3
    ADD    DI,4
    SUB    CX,3
    JNL   DEFAULT

NOTENOUGHCHARS:

; say we had 8 chars so it would go | 8-3 -> 5-3 -> 2-3 -> -1  <- CX FINAL VAL AFTER DEFAULT LOOP for INPUT CHAR = 8
;  so we have 3-1 chars to start with (2) so we need 1 more char 
;  to go from -1 -> 1 we negate CX and boom we have the value of chars we need 
;                                              
    NEG CX                               
    CMP CX,1
    JE  _1CHAR


_2CHAR:
    MOV AL,'='
    MOV [DI+2], AL 
    MOV AL,0

_1CHAR:   
    MOV AL,'='
    MOV [DI+3], AL  
    MOV AL,0 

DONE:

    POP BP
    RET          6               ; Explicit removal 6-bytes from stack AFTER return

    b64Table     DB  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ; for usage as CS:b64Table[0..63]

Base64Encode ENDP

;--------------------------------------------------------------------------
; PROC: int zCount ( ADDRESS str );
;    Computes length of the strings CONTENTS, not including Zero terminator
;
; Stack Diagram:   
;   [BP+4]      String parameter    sourceString      
;   [BP+2]      RA              Return Address
;   [BP+0]      SAVED BP
;
; CALLING CONVENTION:
;       Right-to-left stack order parameters 
;       caller cleans up parameters
;       registers destroyed: AX,BX,CX,DX    
;       registers preserved: SI, DI
;       
;
; INPUT: 
;       sourceString            Address of an ASCII z-String 
;
; OUTPUT:
;       AX      Length of sourceStr
;
; SIDE EFFECT:    
;       NONE
;--------------------------------------------------------------------------
COUNTZ PROC

    PUSH    BP 
    MOV     BP,SP
    PUSH    SI
    PUSH    DI

    MOV BX, [BP+4]
TOP:

    ;Get Char @ INDEX  and checking if its a 0 if 0 end loop
    CMP BYTE PTR [BX],0
    JE BOTTOM
    
    ;INDEX++
    INC BX 

    ;REPEAT LOOP
    JMP TOP 

BOTTOM:
    SUB BX, [BP+4]
    MOV AX, BX

    POP     DI
    POP     SI
    POP     BP
    RET

COUNTZ ENDP
;--------------------------------------------------------------------------
; PROC: pritns a 0 terminated string clear text
; INPUT: BX of zeroterminated string
; 
; OUTPUT: 
; SIDE EFFECT:    Screen printing
;--------------------------------------------------------------------------
PRINTZ PROC

    PUSH BP 
    MOV  BP,SP



    MOV BX, [BP+4]
TOP:

    ;Get Char @ INDEX  and checking if its a 0 if 0 end loop
    CMP BYTE PTR [BX],0
    JE BOTTOM
    
    ;STORE CHAR IN DL  char = DL to print from memory at BX
    MOV DL,[BX]

    ;PrintChar already in dl
    MOV  AH, 2
    INT 21H

    ;INDEX++
    INC BX 

    ;REPEAT LOOP
    JMP TOP 

BOTTOM:

    POP BP
    RET

PRINTZ ENDP

;----------------------------------------------------------------------------------
; Procedure: CopyBuffer
;     Copies one memory buffer of a given size to another
; Input:
;				src buffer		SI
;				dst buffer		DI
;				ACTSTRLEN		CX
; Output:
;    			 N/A
; Side Effects
;     			moves the user string into the dst string (dummy string)
;----------------------------------------------------------------------------------
CopyBuffer  PROC  

	CLD
    REP		MOVSB
	RET

CopyBuffer  ENDP

MAIN    PROC    
    .STARTUP       
   

    PUSH OFFSET mString      ; pushing the SI so we can print out the source String in our print z proc 
    CALL PRINTZ
    ADD SP,2
    
    CALL CRLFPRNT
        

    MOV SI,OFFSET mString  
    MOV DI,OFFSET destString 

    PUSH DI          ; [BP+6]
    PUSH SI          ; [BP+4]

    CALL Base64Encode ; encode passes string output encoded string 
    
    PUSH OFFSET destString      ; pushing the DI so we can print out the destString in our print z proc 
    CALL PRINTZ
    ADD SP,2

    CALL CRLFPRNT
    CALL CRLFPRNT


    PUSH OFFSET maString      ; pushing the SI so we can print out the source String in our print z proc 
    CALL PRINTZ
    ADD SP,2
    
    CALL CRLFPRNT
    


    MOV SI,OFFSET maString  
    MOV DI,OFFSET destString 

    PUSH DI          ; [BP+6]
    PUSH SI          ; [BP+4]

    CALL Base64Encode ; encode passes string output encoded string 
    
    PUSH OFFSET destString      ; pushing the DI so we can print out the destString in our print z proc 
    CALL PRINTZ
    ADD SP,2

    CALL CRLFPRNT
    CALL CRLFPRNT
    






    PUSH OFFSET manString      ; pushing the SI so we can print out the source String in our print z proc 
    CALL PRINTZ
    ADD SP,2
    
    CALL CRLFPRNT
    
    MOV SI,OFFSET manString  
    MOV DI,OFFSET destString 

    PUSH DI          ; [BP+6]
    PUSH SI          ; [BP+4]

    CALL Base64Encode ; encode passes string output encoded string 
    
    PUSH OFFSET destString      ; pushing the DI so we can print out the destString in our print z proc 
    CALL PRINTZ
    ADD SP,2

    CALL CRLFPRNT
    CALL CRLFPRNT






    PUSH OFFSET longString      ; pushing the SI so we can print out the source String in our print z proc 
    CALL PRINTZ
    ADD SP,2
    
    CALL CRLFPRNT
    CALL CRLFPRNT
    
    MOV SI,OFFSET longString 
    MOV DI,OFFSET destString  
    
    PUSH DI          ; [BP+6]
    PUSH SI          ; [BP+4]

    CALL Base64Encode ; encode passes string output encoded string 
    
    PUSH OFFSET destString      ; pushing the DI so we can print out the destString in our print z proc 
    CALL PRINTZ
    ADD SP,2
   
    CALL CRLFPRNT
    CALL CRLFPRNT

; swapping segments es-> ds | ds-> es    // so we can access command line data found in es
    PUSH ES
    PUSH DS
    POP  ES
    POP  DS

 
    MOV CX, 256
    MOV SI,DS:[82h]
    MOV DI, OFFSET cmdString

    CALL CopyBuffer

    MOV SI,DI
    MOV DI, OFFSET destString
    
    PUSH DI          ; [BP+6]
    PUSH SI          ; [BP+4]
    
    CALL Base64Encode

    PUSH OFFSET destString      ; pushing the DI so we can print out the destString in our print z proc 
    CALL PRINTZ
    ADD SP,2
   
    CALL CRLFPRNT
    CALL CRLFPRNT
    
    .EXIT 
MAIN    ENDP    
END 
;   ________________
;  |                |               AND 03 (think binary and 8 bits so 0000_0011) so this can be any hex value under 64
;  |                |                  |
; MOV  dstBuffer    | sourceBuffer[0]  |     SHIFTED 4 
;         |         |           |      |      |   
;         V         v           V      V      V   
;       ixDigit[1] = ((clearText[0] & 0x03)  << 4)    // ((uuuu_VVvv & 0000_0011) SHL 4) == 00vv_0000
;      OR    ->       |       <- remember or means add   
;          ->      (clearText[1] >> 4);                  
;         |                                         
;         |                                      
;         we need the 2nd two bits of the second char so we shift right 4 
;                   
;
;
; VISUAL DST BUFFER)          ABCD EFGH
;                   AND       0000 0011
;                   remaining 0000 00GH         =  ((clearText[0] & 0x03)  << 4)
;                   SHL       00GH 0000
;           IMPLY clearText[0] = ABCD EFGH  clearText[1] = IJKL MNOP
;                                   HAVE: 00GH 0000
;                                   NEED: IJKL MNOP then shift left 4 to get 
;                                         0000 IJKL and then OR it together to get 00GH IJKL 
;                                         which is our 6 bits we need for the 2nd out char 
;                                                  
;                                    OR (clearText[1] >> 4)         (REMEMBER OR MEANS ADD)
;
;                           
;
; 
;     ixDigit[1] = ((clearText[0] & 0x03) << 4)    // ((uuuu_VVvv & 0000_0011) SHL 4) == 00vv_0000
;              |                               //  BINARY OR with...
;               (clearText[1] >> 4);            // (wwww_xxxx SHR 4) == 0000_wwww
;                                                // 00vv_0000|0000_wwww == 00vv_wwww 
;                                                 // Gives our 2nd base64 digit: vvwwww
;