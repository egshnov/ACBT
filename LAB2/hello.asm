.model tiny
.code
org 100h

start:
    mov dx, offset message
    mov ah, 9
    int 21h
    
    mov ax, 4C00h
    int 21h

message db 'Hello from test program!', 13, 10, '$'
end start
