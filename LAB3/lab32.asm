;tasm /m5 lab32.asm
;tlink /t lab32.obj
.MODEL TINY
.8086
.CODE
ORG 100h

MainLoop:
    mov ah,0
    int 16h
    cmp al,1Bh
    je  ExitProg

    mov ch,ah            
    mov bl,al            
    call PrintHex        
    mov [asciiMsg+8],dh
    mov [asciiMsg+9],dl
    mov al,bl
    cmp al,20h
    jb  NonPrint
    cmp al,7Fh
    jnb NonPrint
    jmp StoreChar
NonPrint:
    mov al,'.'
StoreChar:
    mov [asciiMsg+12],al
    lea dx,asciiMsg
    mov ah,9
    int 21h              

    mov bl,ch            
    call PrintHex        
    mov [scanMsg+8],dh
    mov [scanMsg+9],dl
    lea dx,scanMsg
    mov ah,9
    int 21h              

    jmp MainLoop

PrintHex PROC
    push ax
    push cx

    mov al,bl
    mov cl,al
    shr cl,4
    call Nibble2Asc
    mov dh,al

    mov cl,bl
    and cl,0Fh
    call Nibble2Asc
    mov dl,al

    pop cx
    pop ax
    ret
PrintHex ENDP

Nibble2Asc PROC
    push bx

    mov bl,cl
    cmp bl,9
    jbe .d
    add bl,7
.d:  add bl,30h
    mov al,bl

    pop bx
    ret
Nibble2Asc ENDP

ExitProg:
    mov ah,4Ch
    int 21h

asciiMsg db 'ASCII = 00h  ',13,10,'$'
scanMsg  db 'SCAN  = 00h',13,10,'$'

END MainLoop
