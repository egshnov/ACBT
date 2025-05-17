.MODEL TINY
.8086
.CODE
ORG 100h

start:
    mov ax, 3501h
    int 21h
    mov word ptr [old_int1], bx     
    mov word ptr [old_int1+2], es
    
    mov ax, 2501h
    mov dx, OFFSET int1_handler
    int 21h
    
    mov bx, 2000h
    mov es, bx
    xor bx, bx
    
    mov ah, 3Dh
    xor al, al
    mov dx, OFFSET filename
    int 21h
    jc cleanup
    
    mov bx, ax
    mov ah, 3Fh
    mov cx, 0FF00h
    mov dx, 100h
    push es
    pop ds
    int 21h
    
    mov ah, 3Eh
    int 21h
    
    push es
    mov ax, 100h
    push ax

    pushf
    pop ax
    or ax, 100h
    push ax
    popf
    retf
    
cleanup:
    mov ax, 2501h
    lds dx, [old_int1]
    int 21h
    
    mov ax, 4C00h
    int 21h

int1_handler:
    push ax
    push cx
    push dx
    push bx
    push sp
    push bp
    push si
    push di
    push ds
    push es
    
    push cs
    pop ds
    
    mov ah, 09h
    mov dx, OFFSET trace_msg
    int 21h
    
    mov ah, 00h
    int 16h
    
    pop es
    pop ds
    pop di
    pop si
    pop bp
    pop sp
    pop bx
    pop dx
    pop cx
    pop ax
    iret

trace_msg DB 'some instruction', 0Dh, 0Ah, '$'
filename DB 'HELLO.COM', 0
old_int1 DD 0

END start
