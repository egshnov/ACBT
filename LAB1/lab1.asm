; nasm -f lab1.asm -o lab1.bin
; dd if=/dev/zero of=floppy.img bs=512 count=2880
; dd if=ascii_boot.bin of=floppy.img conv=notrunc
; qemu-system-i386 -fda floppy.img

org 7C00h                

    xor     ax, ax
    mov     ds, ax
    mov     es, ax

    mov     si, 32       

row:
    mov     cx, 16       

col:
    cmp     si, 128
    jae     halt

    mov     ax, si
    call    print_hex
    call    print_spc

    mov     bx, si
    mov     al, bl       
    call    print_chr
    call    print_spc

    inc     si
    loop    col

    call    print_nl
    jmp     row


print_chr:
    mov     ah, 0Eh
    mov     bh, 0
    mov     bl, 07h
    int     10h
    ret


print_spc:
    mov     al, ' '
    jmp     print_chr


print_nl:
    mov     al, 13
    call    print_chr
    mov     al, 10
    jmp     print_chr


print_hex:
    push    ax
    push    bx
    push    cx
    push    dx
    push    si

    mov     bx, 16
    mov     cx, 2
    lea     si, hexbuf+2
.gen:
    dec     si
    xor     dx, dx
    div     bx
    add     dl, '0'
    cmp     dl, '9'
    jbe     .store
    add     dl, 7
.store:
    mov     [si], dl
    loop    .gen

    lea     si, hexbuf
    mov     cx, 2
.out:
    mov     al, [si]
    call    print_chr
    inc     si
    loop    .out

    
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

hexbuf  db '00'

halt:   jmp $

times 510-($-$$) db 0
dw 0AA55h
