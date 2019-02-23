; ASSIGNMENT #1 - HELLOASM - Validating your MSDOS development enviroment 
; AUTHOR: Jonah Valdez. 

.MODEL SMALL   

.386            
;-----------------------------------------------------------------------------
; S T A C K  S E G M E N T
;-----------------------------------------------------------------------------
.STACK 4096    




;-----------------------------------------------------------------------------
; D A T A  S E G M E N T 
;-----------------------------------------------------------------------------
.DATA        
        ;Have a max size for the password
        StrSize = 64

        ;Need buffer for the string
        PW_BUFFER       DB      StrSize Dup(0)


        PW_Prompt       10, 13  "Password: $"


        ;This is needed to move the current position to one place befor the prompt password:
        OFFSET PW_Prompt + 1  


        ;We need values to use to check to see if the input is valid, based on the askii table.

        ;the lowist ascii value possible
        ValidCharMin = 33

        ;highist ascii value possible.
        ValidCharMax = 127




        ;we will also need to set the aski code for the key enter to its own place to check if it is pressed in the check for the loop.

        Enterkey = 

        ;askii value for delete.
        deletekey = 127



        ;Likewise we will need to save the aski codes for backspace and delete so we can test for them in our loop check.

       
;------------------------------------------------------------------------------
; C O D E  S E G M E N T 
;------------------------------------------------------------------------------
.CODE           
        
 ;In this segment we will need some type of print password functions that we can call

        ;It should be able to have the option to print stars and the password
                

        ;input
        ;AH--->Bool : 0 Print Chars, Not 0 Print "*"
        ;AL == alternate char "*"
;DX is the offset of the askii code *


;--------------------------------------------------------------------------
PRINTZ PROC

        ;Get Char @ DX 
        MOV      [DX], [OFFSET PW_BUFFER]

        ;DX++
        INC     [DX]

        ;PrintChar
        MOV     


        RET


PRINTZ END






        

MAIN PROC
        
        .STARTUP
 


        ;to take in a char use   AH,8
                               ; Int 21h



        ;Prompt the user to enter a password

        ;index = 0
       ; LOOP
                ;READ CHAR into AL

                ;IF AL == BACKSPACE OR DELETE 
                ;       Remove last char from password buffer
                ;       reprint the screen
                ;       jmp TOP

                ;       
                ;IF AL ==  ENTER
                ;       should check minimum password length here? 
                ;       JMP Past loop


                ;IF AL == INVALID CHARACTER ( > 127 , SPACE, TAB, <=32 )
                ;       JMP     top

                ;;;;;;;;;;Overrun the maximum length??

                ;*** CHAR IS VALID ***
                ;Put the Char into Buffer[index]
                ;Append binary zero to buffer[index+1]
                index = index + 1

                ;Print a '*'.
        ;ENDLOOP


        ; Print he prompt
        ; Print the password in clear text 

;=======================================================================================================================


        ;Prompt the user to enter a password
        MOV     PW_Prompt 
        MOV     AH,9
        MOV     DX, OFFSET PW_Prompt

        ;index = 0
        MOV     DI, 0
TOPLOOP: 
        ;READ CHAR into AL
        MOV     AH,8
        INT     21h



         ;IF AL ==  ENTER
                ;       should check minimum password length here? 
                ;       JMP Past loop
        CMP     AL, 13
        JMP     ENDLOOP


         ;IF AL == INVALID CHARACTER ( > 127 , SPACE, TAB, ; <=32 )
                ;       JMP     top

        CMP     AL, 9
        
        



ENDLOOP:


MAIN    ENDP


END



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        ; LOOP
        ;       READ CHAR into AL


                ;CHECK TO SEE IF CHAR IS VALID
                ;---------------------------------------------------------------------------------------------------------------------------------------------       
                        ;We will need some type of ?loop? that will check if the char passed from user is a valid char.

                        ;(It might be possible to split the check for invalid chars up to make it easier to check different things)

                                ;if the char passed is invalid use a JMP comand to jump back to the top of loop.

                                        ;and do not push anything onto stack or reprint stars.

                        ;
                ;---------------------------------------------------------------------------------------------------------------------------------------------




                ;CHECK TO SEE IF BACKSPACE OR DELETE IS pressed
                ;---------------------------------------------------------------------------------------------------------------------------------------------
                        ;We will need a loop to check to see if the char entered is a backspace or delete.

                                ;if the key pressed is not backspace or delete, then move on to the next loop.

                                ;if the key pressed is a backspace or a delete then use pop to pop the char off the stack.
                                        ;then reprint the correct number of stars based on the index of the stack - 1.
                                        ;once reprinted jump 
                ;--------------------------------------------------------------------------------------------------------------------------------------------


                ;CHECK TO SEE IF ENTER IS PRESSED AND PRINTING STRING BACK TO USER.
                ;--------------------------------------------------------------------------------------------------------------------------------------------
                        ;We will need a check to see if Enter is pressed to call the print password to screen function.

                        ;first we will need to check to see if the stack index is == to 0, if it is then print no password entered.
                                ;if the stack index is not == 0, then print the password back to the screen using the print function.
                ;--------------------------------------------------------------------------------------------------------------------------------------------

                ;Put the Char into Buffer.

                ;Print a '*'.


        ;ENDLOOP

       
        .EXIT
