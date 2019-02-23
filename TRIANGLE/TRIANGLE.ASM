; Ariel Guerrero Assignemt - Triangle
.MODEL SMALL
            
.386        
            

;--------------------------------------------------------------------------
; S T A C K  S E G M E N T
;--------------------------------------------------------------------------
.STACK 4096  
;--------------------------------------------------------------------------
; D A T A  S E G M E N T
;--------------------------------------------------------------------------
.DATA   
prompt			DB 13,10 ,"ASSIGNMENT - TRIANGLE - BY: ARIEL GUERRERO $"
				
crlf			DB	13,10,'$' 			; new line 


;---------------------------------------------------------------------------
; C O D E  S E G M E N T
;---------------------------------------------------------------------------
.CODE  

;----------------------------------------------------------------------------------
; Procedure: TOTRI
;     Provide main program driver, entry point at .STARTUP and exit at .EXIT
; Input:
;			BH : 0 -------> 10
;           BL : 0 -------> 10
;           DL : *,| and crlf
;
; Output:
;			Top of the triangle     
;                       |
;                       **|            
;                       ***|
;                       ****|
;                       *****|
; Side Effects
;           N/A
;----------------------------------------------------------------------------------
TOTRI  PROC

        MOV BH,0   
        MOV BL,0
        MOV AH,2
    TOP:
        CMP BH,10
        JE ENDLOOP
        MOV BL,0
    
    TOPTRI:
        CMP BL,BH
        JE BOTTRI
        MOV DL,'*'
        INT 21H
        
        INC BL
        JMP TOPTRI
    BOTTRI:
        
        MOV DL ,'|'
        INT 21H

        MOV DL,10
        INT 21H
        
        MOV DL,13
        INT 21H
        
        INC BH
        JMP TOP
    ENDLOOP:
        RET
TOTRI  ENDP

;----------------------------------------------------------------------------------
; Procedure: TOTRI
;     Provide main program driver, entry point at .STARTUP and exit at .EXIT
; Input:
;			BH : 0 -------> 10
;           BL : 0 -------> 10
;           DL : *,| and crlf
;
; Output:
;			Bottom of the triangle         
;                   *****|
;                   ****|
;                   ***|                 
;                   **|   
;                   *|    
;                   |    
; Side Effects
;           N/A
;----------------------------------------------------------------------------------
BOTRI  PROC

        MOV BH,10
        MOV BL,0
        MOV AH,2
    TOP:
        CMP BH,0
        JL ENDLOOP
        MOV BL,0
    
    TOPTRI:
        CMP BL,BH
        JE BOTTRI
        MOV DL,'*'
        INT 21H
        
        INC BL
        JMP TOPTRI
    BOTTRI:
        
        MOV DL ,'|'
        INT 21H
        
        MOV DL,10   ;cr 
        INT 21H
        
        MOV DL,13   ; lf
        INT 21H
        
        
        DEC BH
        JMP TOP
    ENDLOOP:
        RET
BOTRI ENDP



;----------------------------------------------------------------------------------
; Procedure: MAIN
;     Provide main program driver, entry point at .STARTUP and exit at .EXIT
; Input:
;			N/A    
; Output:
;           prompt (Assignemt Assignemt name and my name )
;
; Side Effects
;           CALL TOTRI and CALL BOTRI to print the top and bottom of the triangle
;----------------------------------------------------------------------------------
MAIN    PROC    
                

        .STARTUP 
	
		
		MOV 	AH,9					;Outputs user prompt
		MOV 	DX, OFFSET prompt
		INT 	21h					


		MOV 	AH,9					; new line
		MOV		DX,OFFSET crlf
		INT 	21H

        CALL    TOTRI
        CALL    BOTRI
    
		.EXIT							; exits program


MAIN    ENDP
END										;end code