; Ariel Guerrero Assignemt 2 - IN/OUT
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

crlf			DB	13,10,'$' 			; new line 

maxstrlen       DB  255 				; buffer[0]

actstrlen		DB  ?  					; buffer[1]				

userstr			DB 255 DUP(?) 			;buffer[2-255]


promptu			DB 13,10 ,"Enter a String: $"
				
;---------------------------------------------------------------------------
; C O D E  S E G M E N T
;---------------------------------------------------------------------------
.CODE  

MAIN    PROC    
                

        .STARTUP 

STARTLOOP:  							;start of our loop	

	
		
		MOV 	AH,9					;Outputs user prompt
		MOV 	DX, OFFSET promptu	
		INT 	21h					


		MOV 	[actstrlen],0			; sets input buffer actual length to 0
		MOV 	AH, 0Ah					; takes in input 
		MOV 	DX, OFFSET maxstrlen				
		INT 	21h						

		CMP		[actstrlen],0			;compare if length is zero
		JZ 		ENDLOOP
		
		MOV 	AH,9					; new line
		MOV		DX,OFFSET crlf
		INT 	21H
		
		MOV 	AH,9					;prints out the word
		MOV 	DX, OFFSET userstr	
		INT 	21h	
		
		MOV 	AH,9					; new line
		MOV		DX,OFFSET crlf
		INT 	21H
		JMP 	STARTLOOP				; restarts at the top till we get 0 input
		
ENDLOOP: 
		.EXIT							; exits program


MAIN    ENDP
END										;end code