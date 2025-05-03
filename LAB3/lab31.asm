;tasm /m5 lab31.asm
;tlink /t lab31.obj

                .model  tiny
                .8086
                .code
                org     100h

start:          cli                     
                mov     ax,3509h        
                int     21h             
                mov     word ptr oldSeg,es
                mov     word ptr oldOfs,bx

                call    install_patch   

                push    cs
                pop     ds
                mov     dx, offset newISR
                mov     ax,2509h        
                int     21h
                sti

wait_key:       xor     ah,ah           
                int     16h
                cmp     al,27
                jne     wait_key

quit:           cli
                mov     dx, word ptr oldOfs
                mov     ds, word ptr oldSeg
                mov     ax,2509h        
                int     21h
                sti

                mov     ax,4C00h        
                int     21h

newISR  proc    far
                pushf                      
                push    ax bx cx dx si di ds es bp

                in      al,60h             
                mov     ah,al              

                mov     al,20h             
                out     20h,al

                test    ah,80h             
                jnz     chain_orig

                and     ah,7Fh             
                mov     al,ah
                call    print_hex_al       

                mov     al,13              
                call    bios_print_al
                mov     al,10              
                call    bios_print_al

chain_orig:     pop     bp es ds di si dx cx bx ax
                popf
                db      0EAh               
oldIsrPtr       dw      0                  
oldIsrSeg       dw      0
newISR  endp

bios_print_al   proc    near
                push    ax bx es    
                mov     ah,0Eh
                mov     bh,0
                mov     bl,7
                int     10h
                pop     es bx ax
                ret
bios_print_al   endp

print_hex_al    proc    near           ; AL → "XY" hex
                push    ax bx
                mov     bl,al
                mov     al,bl
                shr     al,4
                call    half_nibble
                mov     al,bl
                and     al,0Fh
                call    half_nibble
                pop     bx ax
                ret
print_hex_al    endp

half_nibble     proc    near
                cmp     al,9
                jbe     is_digit
                add     al,'A'-10
                jmp     short out1
is_digit:       add     al,'0'
out1:           call    bios_print_al
                ret
half_nibble     endp

install_patch    proc    near
                mov     ax,word ptr oldOfs
                mov     word ptr oldIsrPtr,ax
                mov     ax,word ptr oldSeg
                mov     word ptr oldIsrSeg,ax
                ret
install_patch    endp

oldOfs          dw  ?
oldSeg          dw  ?

                end     start