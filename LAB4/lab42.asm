.model small
.386
.stack 100h

ASSUME cs:@code, ds:@code
.code
    org 100h

hexChars   db '0123456789ABCDEF'
msgBus     db 'Bus: $'
msgDev     db ' Dev: $'
msgFunc    db ' Func: $'
msgVend    db ' VendorID: $'
msgDevID   db ' DeviceID: $'
msgVendName db '  [$'
msgDevName  db '] [$'
crlf       db ']',13,10,'$'
currFunc   db 0

VendorTable:
    dw 8086h
    db 'Intel$'
    dw 1B36h
    db 'RedHat$'
    dw 1AF4h
    db 'VirtIO$'
    dw 0FFFFh

IntelDevices:
    dw 1237h
    db 'PCI Memory$'
    dw 7000h
    db 'PIIX3 ISA$'
    dw 7010h
    db 'PIIX3 IDE$'
    dw 7113h
    db 'PIIX4 ACPI$'
    dw 100Eh
    db '82540EM ETH$'
    dw 2668h
    db 'ICH6 AC97$'
    dw 2934h
    db 'ICH9 LPC$'
    dw 2935h
    db 'ICH9 BUS$'
    dw 2936h
    db 'ICH9 IDE$'
    dw 293Ah
    db 'ICH9 USB$'
    dw 0FFFFh

RedHatDevices:
    dw 0100h
    db 'QXL GPU$'
    dw 1002h
    db 'VirtIO BAL$'
    dw 1003h
    db 'VirtIO NET$'
    dw 0FFFFh

start:
    push cs
    pop ds

    xor  ebx,ebx
BusLoop:
    cmp  ebx,256
    jge  Done

    xor  ecx,ecx
DevLoop:
    cmp  ecx,32
    jge  NextBus

    mov  byte ptr currFunc,0

FuncLoop:
    cmp  byte ptr currFunc,8
    jge  NextDev

    mov  dl,[currFunc]
    xor  dh,dh

    mov  eax,80000000h
    mov  esi,ebx
    shl  esi,16
    or   eax,esi
    mov  esi,ecx
    shl  esi,11
    or   eax,esi
    mov  esi,edx
    shl  esi,8
    or   eax,esi

    mov  dx,0CF8h
    out  dx,eax
    mov  dx,0CFCh
    in   eax,dx

    mov  edi,eax
    mov  di,ax
    cmp  ax,0FFFFh
    je   SkipFuncPrint

    push dx
      mov  dx,offset msgBus
      mov  ah,9
      int 21h
    pop  dx
    mov  ax,bx
    call PrintHexByte

    push dx
      mov  dx,offset msgDev
      mov  ah,9
      int 21h
    pop  dx
    mov  ax,cx
    call PrintHexByte

    push dx
      mov  dx,offset msgFunc
      mov  ah,9
      int 21h
    pop  dx
    mov  al,[currFunc]
    call PrintHexByte

    push dx
      mov  dx,offset msgVend
      mov  ah,9
      int 21h
    pop  dx
    mov  ax,di
    call PrintHexWord

    push dx
      mov  dx,offset msgDevID
      mov  ah,9
      int 21h
    pop  dx
    mov  eax,edi
    shr  eax,16
    call PrintHexWord

    push dx
    mov  dx,offset msgVendName
    mov  ah,9
    int 21h
    pop  dx
    
    push di
    call FindVendorName
    
    push dx
    mov  dx,offset msgDevName
    mov  ah,9
    int 21h
    pop  dx
    
    pop  di
    call FindDeviceName

    push dx
      mov  dx,offset crlf
      mov  ah,9
      int 21h
    pop  dx

SkipFuncPrint:
    inc  byte ptr currFunc
    jmp  FuncLoop

NextDev:
    inc  ecx
    jmp  DevLoop

NextBus:
    inc  ebx
    jmp  BusLoop

Done:
    mov  ah,4Ch
    int 21h

PrintHexWord proc near
    push edx
    push ax
    push bx
    push cx
    mov  bx,ax
    mov  cx,4
PWL:
    mov  dx,bx
    and  dx,0F000h
    shr  dx,12
    call PrintHexNibble
    shl  bx,4
    loop PWL
    pop  cx
    pop  bx
    pop  ax
    pop  edx
    ret
PrintHexWord endp

PrintHexByte proc near
    push edx
    push ax
    push bx
    mov  bl,al
    shr  bl,4
    mov  dx,bx
    call PrintHexNibble
    mov  bl,al
    and  bl,0Fh
    mov  dx,bx
    call PrintHexNibble
    pop  bx
    pop  ax
    pop  edx
    ret
PrintHexByte endp

PrintHexNibble proc near
    push ax
    push bx
    mov  bx,offset hexChars
    add  bx,dx
    mov  al,[bx]
    mov  dl,al
    mov  ah,2
    int 21h
    pop  bx
    pop  ax
    ret
PrintHexNibble endp

FindVendorName proc near
    push ax
    push bx
    push cx
    
    mov bx,offset VendorTable
SearchVendor:
    mov ax,[bx]
    cmp ax,0FFFFh
    je VendorNotFound
    
    cmp ax,di
    je FoundVendor
    
    add bx,2
NextVendChar:
    inc bx
    cmp byte ptr [bx],'$'
    jne NextVendChar
    inc bx
    jmp SearchVendor

FoundVendor:
    add bx,2
    mov dx,bx
    mov ah,9
    int 21h
    jmp VendorDone

VendorNotFound:
    mov dx,offset UnknownStr
    mov ah,9
    int 21h

VendorDone:
    pop cx
    pop bx
    pop ax
    ret
FindVendorName endp

FindDeviceName proc near
    push ax
    push bx
    push cx
    push si

    mov eax,edi
    shr eax,16
    mov si,ax

    cmp di,8086h
    je  SearchIntel
    cmp di,1B36h
    je  SearchRedHat
    cmp di,1AF4h
    je  SearchRedHat
    jmp DeviceNotFound

SearchIntel:
    mov bx,offset IntelDevices
    jmp SearchDevice

SearchRedHat:
    mov bx,offset RedHatDevices

SearchDevice:
    mov ax,[bx]
    cmp ax,0FFFFh
    je DeviceNotFound
    
    cmp ax,si
    je FoundDevice
    
    add bx,2
NextDevChar:
    inc bx
    cmp byte ptr [bx],'$'
    jne NextDevChar
    inc bx
    jmp SearchDevice

FoundDevice:
    add bx,2
    mov dx,bx
    mov ah,9
    int 21h
    jmp DeviceDone

DeviceNotFound:
    mov dx,offset UnknownStr
    mov ah,9
    int 21h

DeviceDone:
    pop si
    pop cx
    pop bx
    pop ax
    ret
FindDeviceName endp

UnknownStr db 'Unknown$'

end start
