.MODEL TINY
.8086
.CODE
ORG 100h

start:
    jmp main

handler:
    pushf
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
    
    sub sp, 2
    mov bp, sp

    mov ax, cs
    mov ds, ax
    
    mov al, [original_byte_storage]
    mov byte ptr [bp], al

    mov ah, 09h
    mov dx, OFFSET msg_break
    int 21h
    
    mov ax, 2000h
    mov es, ax
    mov di, [patch_offset]
    add di, 100h
    mov al, [bp]
    mov es:[di], al
    
    push bx
    mov ah, 3Dh
    mov al, 2
    mov dx, OFFSET filename
    int 21h
    jc handler_skip_disk_restore

    mov bx, ax

    mov ax, 4200h
    xor cx, cx
    mov dx, [patch_offset]
    int 21h
    jc handler_close_and_skip_disk_restore

    mov ah, 40h
    mov cx, 1
    mov dx, OFFSET original_byte_storage
    int 21h

handler_close_and_skip_disk_restore:
    mov ah, 3Eh
    int 21h

handler_skip_disk_restore:
    pop bx

    mov ax, 2503h
    lds dx, [old_int3]
    int 21h
    
    dec word ptr [bp+24]

    add sp, 2
    
restore_end:
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
    popf
    iret

main:
    mov ah, 09h
    mov dx, OFFSET starting
    int 21h
    
    mov byte ptr [int3_hooked_flag], 0
    mov byte ptr [disk_patched_flag], 0

    mov ax, 3503h
    int 21h
    mov word ptr [old_int3], bx
    mov word ptr [old_int3+2], es
    
    mov ax, 2503h
    mov dx, OFFSET handler
    int 21h
    mov byte ptr [int3_hooked_flag], 1

    mov ah, 3Dh
    mov al, 2
    mov dx, OFFSET filename
    int 21h
    jnc patch_open_ok
    jmp cleanup_and_exit

patch_open_ok:
    mov bx, ax
    
    mov ax, 4200h
    xor cx, cx
    mov dx, [patch_offset]
    int 21h
    jnc patch_seek_read_ok
    jmp close_patch_file_and_cleanup

patch_seek_read_ok:
    mov ah, 3Fh
    mov cx, 1
    mov dx, OFFSET original_byte_storage
    int 21h
    jnc patch_read_ok
    jmp close_patch_file_and_cleanup

patch_read_ok:
    mov ax, 4200h
    xor cx, cx
    mov dx, [patch_offset]
    int 21h
    jnc patch_seek_write_ok
    jmp close_patch_file_and_cleanup

patch_seek_write_ok:
    mov ah, 40h
    mov cx, 1
    mov dx, OFFSET int3_byte
    int 21h
    mov byte ptr [disk_patched_flag], 1
    jnc patch_write_ok
    jmp close_patch_file_and_cleanup

patch_write_ok:
    mov ah, 3Eh
    int 21h
    
    mov si, 2000h
    mov es, si
    
    mov ah, 3Dh
    xor al, al
    mov dx, OFFSET filename
    int 21h
    jnc open_load_ok
    jmp cleanup_and_exit

open_load_ok:
    mov bx, ax
    
    mov ah, 3Fh
    mov cx, 0FF00h
    mov dx, 100h
    push es
    pop ds
    int 21h
    push cs
    pop ds
    jnc read_successful
    jmp close_load_file_and_cleanup

read_successful:
    mov ah, 3Eh
    int 21h
    
    mov ax, es
    mov ds, ax
    
    push es
    mov ax, 100h
    push ax
    
    retf
    
    jmp final_exit

close_patch_file_and_cleanup:
    mov ah, 3Eh
    int 21h
    jmp cleanup_and_exit

close_load_file_and_cleanup:
    mov ah, 3Eh
    int 21h
    jmp cleanup_and_exit
    
cleanup_and_exit:
    push cs
    pop ds

    cmp byte ptr [disk_patched_flag], 1
    jne restore_int3_only_if_hooked

    mov ah, 3Dh
    mov al, 2
    mov dx, OFFSET filename
    int 21h
    jc restore_int3_only_if_hooked

    mov bx, ax

    mov ax, 4200h
    xor cx, cx
    mov dx, [patch_offset]
    int 21h
    jnc unpatch_seek_ok_cleanup
    mov ah, 3Eh
    int 21h
    jmp restore_int3_only_if_hooked

unpatch_seek_ok_cleanup:
    mov ah, 40h
    mov cx, 1
    mov dx, OFFSET original_byte_storage
    int 21h
    mov ah, 3Eh
    int 21h

restore_int3_only_if_hooked:
    cmp byte ptr [int3_hooked_flag], 1
    jne final_exit

    push cs
    pop ds
    mov ax, 2503h
    lds dx, [old_int3]
    int 21h
                 
final_exit:
    mov ax, 4C00h
    int 21h

filename DB 'HELLO.COM', 0
msg_break DB '*** BREAKPOINT HIT! ***', 0Dh, 0Ah, '$'
starting DB 'Starting breakpoint program...', 0Dh, 0Ah, '$'
original_byte_storage DB 0
patch_offset DW 7
int3_byte DB 0CCh
old_int3 DD 0
int3_hooked_flag DB 0
disk_patched_flag DB 0

END start