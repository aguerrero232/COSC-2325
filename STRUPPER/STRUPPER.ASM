; ASSIGNMENT  - STRUPPER  
; Author ARIEL GUERRERO


.MODEL SMALL    
.386            
               
;================================================================================
; STACK SEGMENT
;=================================================================================
.STACK 4096     


;=================================================================================
; DATA SEGMENT
;===================================================================================
.DATA 		
	Message		DB  13, 10,"Enter a String: ","$"
	CRLF		DB 	13, 10," ", '$'
	MAXSTRLEN	DB 	64
	ACTSTRLEN	DB 	?
	
	USERSTR		DB 	64 DUP(?)
	dummySTR		DB 	"                $", 13, 10
	dummySTR2		DB 	"                $", 13, 10
;==================================================================================
;CODE SEGMENT
;==================================================================================
.CODE  


;----------------------------------------------------------------------------------
; Procedure: MAIN
;     Provide main program driver, entry point at .STARTUP and exit at .EXIT
; Input:
;			user input from keyboard using ---> ah,0ah    
; Output:
;			user str all lower 	   
;			user str all upper
;			user str sqwap cases
;			original user str
;
; Side Effects
;    N/A 
;----------------------------------------------------------------------------------
MAIN    PROC   

      .STARTUP        
     
	 MOV	AX, DS
	 MOV	ES, AX

TOPLOOP:

	;prompt user
	MOV		AH, 9                   
	MOV		DX, OFFSET Message     
	INT		21h      
	
	; take in user input
	MOV		[ACTSTRLEN], 0
	MOV		AH, 0Ah
	MOV		DX, OFFSET MAXSTRLEN
	INT		21h

	; make sure input is greater than 0
	CMP		[ACTSTRLEN], 0
	JZ 		PASTLOOP	

	; moving max length into cx 
	MOV		CX, 16
	CALL 	CopyBuffer
	
	;make user string lower case
	CALL 	MakeLower

	MOV		AH, 9
	MOV		DX, OFFSET CRLF
	INT		21h

	;print LowerCase buffer
	MOV		AH, 9
	MOV		DX, OFFSET dummySTR
	INT		21h

	MOV		AH, 9
	MOV		DX, OFFSET CRLF
	INT		21h

	CALL 	CopyBuffer

	;make string UpperCase
	CALL 	MakeUpper

	;print UpperCase buffer
	MOV		AH, 9
	MOV		DX, OFFSET dummySTR
	INT		21h

	MOV		AH, 9
	MOV		DX, OFFSET CRLF
	INT		21h
	
	
	MOV		CX, 16
	CALL 	CopyBufSW

	;make string UpperCase
	CALL 	MakeSwap

	;print Swapped buffer
	MOV		AH, 9
	MOV		DX, OFFSET dummySTR2
	INT		21h

	MOV		AH, 9
	MOV		DX, OFFSET CRLF
	INT		21h

	;print original string as is
	MOV		AH, 9
	MOV		DX, OFFSET USERSTR
	INT		21h

	MOV		AH, 9
	MOV		DX, OFFSET CRLF
	INT		21h

	JMP 	PASTLOOP

PASTLOOP:
        
      .EXIT

MAIN    ENDP    

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

	LEA		SI, OFFSET USERSTR
	LEA		DI, OFFSET dummySTR
	REP		MOVSB

	RET

CopyBuffer  ENDP
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
CopyBufSW  PROC  

	CLD

	LEA		SI, OFFSET USERSTR
	LEA		DI, OFFSET dummySTR2
	REP		MOVSB

	RET

CopyBufSW  ENDP
;----------------------------------------------------------------------------------
; Procedure: MakeLower
;     Changes string to all Lowercase
; Input:
;			dummyStr : AL	
;			index of current char : BX
;
; Output:
;     		N/A
;
; Side Effects
;     		dummy string is now all lowercase 
;----------------------------------------------------------------------------------
MakeLower  PROC   

	MOV		BX, 0	

TOPLOOP:

	MOV		AL, dummySTR[BX]
	
	CMP		BX, 16
	JE 		PASTLOOP

	CMP		AL, 40h		;check if uppercase letter 40h is 16x4 (16+16=32*2 = 64 )
	JLE 	BOTLOOP

	CMP		AL, 5Bh		;5BH is 5*16 +11 == (91)
	JGE 	BOTLOOP

	ADD		AL, 20h		; 20h == 32 
	MOV 	dummySTR[BX], AL

BOTLOOP:

	ADD		BX, 1
	JMP 	TOPLOOP

PASTLOOP:
	
	RET

MakeLower  ENDP

;----------------------------------------------------------------------------------
; Procedure: MakeUpper
;     Changes string to all Lowercase
; Input:
;			dummyStr : AL	
;			index of current char : BX
;
; Output:
;     		N/A
;
; Side Effects
;     		dummy string is now all uppercase
;----------------------------------------------------------------------------------
MakeUpper  PROC  
	
	MOV		BX, 0		

TOPLOOP:
	
	MOV		AL, dummySTR[BX]

	CMP		BX, 16
	JE		PASTLOOP

	CMP		AL, 60h		;check if lowercase letter
	JLE 	BOTLOOP

	CMP		AL, 7Bh
	JGE 	BOTLOOP

	SUB		AL, 20h
	MOV		dummySTR[BX], AL

BOTLOOP:

	ADD		BX, 1
	JMP 	TOPLOOP

PASTLOOP:
	
	RET

MakeUpper  ENDP

;----------------------------------------------------------------------------------
; Procedure: MakeSwap
;     Changes string to all Lowercase
; Input:
;			dummyStr : AL	
;			index of current char : BX
;
; Output:
;     		N/A
;
; Side Effects
;     		dummy string is now lowercase where it was uppercase 
;			and uppercase where it was lowercase 
;----------------------------------------------------------------------------------
MakeSwap  PROC   
	MOV 	BX,0
TOP:

	;Hold value of DI[BX] in al
	MOV        AL, dummySTR2[BX]

	;if  BX = CX
	CMP        BX,16

	;if count >DX
	JE        BOTTOM

	;if value > 'Z' 90, continue
	CMP        AL, 90
	JLE        PastUpper

	;if value <= 'z' 122, check lowercase
	CMP        AL, 122
	JLE        PastLower

PastUpper:

	;if value >= 'A' 65, we lowercase
	CMP        AL, 65
	JL        INCREM

	;value is withing 65-90
	ADD        AL,32

	;SWAP VALUE
	MOV       dummySTR2[BX], AL
	INC        BX
	JMP        TOP

PastLower:
	;if value >= 'a' 97,  uppercase
	CMP        AL, 97
	JL        INCREM

	;value is within 97-122
	SUB        AL,32

	;ADD VALUE IN
	MOV        dummySTR2[BX], AL
	INC        BX
	JMP        TOP
	
INCREM:
	INC        BX
	JMP        TOP

BOTTOM:
	RET
MakeSwap  ENDP

END
