.model small

.stack 4096

.data
passmaxS =20
prompt db 10 dup(?),10,13
  db  "Enter your pass :$"
  db 10 dup(?)

passMarker  db  "PASSWORD: $"

pass     db  passmaxS dup(?) ; 7 plus term char $

Ast     db  "*$"

crlf   db  13, 10,'$'

.code
    mov     ax, @data
    mov     ds,ax

    ; Display Name prompt
    lea     dx, prompt
    mov     ah, 9
    int     21h

    mov     cx, passmaxS  ; gets up to 20
  
    lea     si, pass ; buffer to hold name
    lea     dx, Ast ; display *

TOPLOOP:
    ; get char typed
    mov     ah, 7
    int     21h
    ; save in our buffer
    mov     byte ptr[si], al

    ; Display Asterick
    ; Asterick already in dx
    mov     ah, 9
    int     21h

    ; increase our buffer pointer
    inc     si

    ; if enter jump to the BOTTOMLOOP
    CMP     AL,13
    JEZ      BOTTOMLOOP


    dec     cx
    JEZ     BOTTOMLOOP ;continue until met 0
    JMP     TOPLOOP

BOTTOMLOOP:

    ; properly terminate our string
    mov     byte ptr[si], "$"

    ; insert blank line
    lea     dx, crlf
    mov     ah, 9
    int     21h

    ; display password 
    lea     dx, passMarker
    mov     ah, 9
    int     21h

    ; Now display entered name
    lea     dx, pass
    mov     ah, 9
    int     21h
  
  .EXIT

end