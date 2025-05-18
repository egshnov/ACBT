.model tiny
.code
org 100h

start:
    mov dx, offset message1
    mov ah, 9
    int 21h
    
    mov dx, offset message2
    mov ah, 9
    int 21h

    mov ax, 4C00h
    int 21h

message1 db 'Hello from test program!', 13, 10, '$'
message1 db 'Second message', 13, 10, '$'
end start
