; Author: Ariel Isidro Guerrero

; Practice Program learning how to add before I go to class because I want to
; be a know it all!

.model small
.stack 4096
.data
msg     db  " input a number !$"
msg2    db  " the sum is:$"

.code
prct2   PROC
mov ax,@data           ; takes data and stores it into ax
mov ds,ax              ; takes ax and stores that in the data segment

lea dx,msg             ; loading the effective address of msg 
mov ah,9               ; 9 means we are printing a string
int  21h

mov ah,1               ; here's where we take in the number input
int 21h

mov bl,al              ; we are storing the number we got in bl

lea dx,msg             ; here we are prompting the user for the 2nd number
mov ah,9
int 21h

mov ah,1               ; just like how 9 is for strings 1 is for take in a character
int 21h

mov cl,al              ; storing the number in cl (or al??)

lea dx,msg2            ; loading up the effective address of msg2
mov ah,9               ; and printing it to the screen (ah,9 is print string)
int 21h

sub bl,30h             ; here is where we subtract im guessing
sub cl,30h             ; what is 30h i need to understand this part better

add cl,bl              ; pretty sure this is add but i have no idea how and why the 
add cl,30h             ; numbers are stored where they are and what calls we are making

mov dl,cl              ; i think this is where we put the two numbers together
mov ah,2               ; and the call for ah,2 is to print a char 
int 21h

mov ah,4ch             ; what is 4ch?
int 21h


prct2   endP

end prct2
x
