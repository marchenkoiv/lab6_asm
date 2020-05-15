.model medium
public  inputline,input,readfile,output,writefile,menu,algorithm
extrn   start:far
    .code
inputline   proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ah,3fh
    xor bx,bx
    mov cx,80
    mov dx,@@buffer
    int 21h
    jc @@ex
    cmp ax,80
    jne @@m
    stc
    jmp short @@ex
@@m:    mov di,@@buffer
    dec ax
    dec ax
    add di,ax
    xor al,al
    stosb
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
input   proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    xor bx,bx
    mov cx,4095
    mov dx,@@buffer
@@m1:   mov ah,3fh
    int 21h
    jc @@ex
    cmp ax,2
    je @@m2
    sub cx,ax
    jcxz @@m2
    add dx,ax
    jmp @@m1
@@m2:   mov di,@@buffer
    add di,4095
    sub di,cx
    xor al,al
    stosb
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
output  proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov di,@@buffer
    xor al,al
    mov cx,0ffffh
    repne scasb
    neg cx
    dec cx
    dec cx
    jcxz @@ex
    cmp cx,4095
    jbe @@m
    mov cx,4095
@@m:    mov ah,40h
    xor bx,bx
    inc bx
    mov dx,@@buffer
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
    
readfile    proc
    locals @@
@@buffer    equ [bp+6]
@@filnam    equ [bp+8]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax,3d00h
    mov dx,@@filnam
    int 21h
    jc @@ex
    mov bx,ax
    mov cx,4095
    mov dx,@@buffer
@@m1:   mov ah,3fh
    int 21h
    jc @@er
    or ax,ax
    je @@m2
    sub cx,ax
    jcxz @@m2
    add dx,ax
    jmp @@m1
@@m2:   mov di,@@buffer
    add di,4095
    sub di,cx
    xor al,al
    stosb
    mov ah,3eh
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
@@er:   mov ah,3eh
    int 21h
    stc
    jmp @@ex
    endp
writefile proc
    locals @@
@@filnam    equ [bp+8]
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ah,3ch
    xor cx,cx
    mov dx,@@filnam
    int 21h
    jc @@ex
    mov bx,ax
    mov di,@@buffer
    xor al,al
    mov cx,0ffffh
    repne scasb
    neg cx
    dec cx
    dec cx
    jcxz @@ex
    cmp cx,4095
    jbe @@m
    mov cx,4095
@@m:    mov ah,40h
    mov dx,@@buffer
    int 21h
    jc @@er
    mov ah,3eh
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
@@er:   mov ah,3eh
    int 21h
    stc
    jmp @@ex
    endp
menu    proc
    locals @@
@@ax        equ [bp-82]
@@buffer    equ [bp-80]
@@items equ [bp+6]
    push bp
    mov bp,sp
    sub sp,80
    push ax
@@m:    push @@items
    call output
    pop ax
    jc @@ex
    push ds
    push es
    push ss
    push ss
    pop ds
    pop es
    mov ax,bp
    sub ax,80
    push ax
    call inputline
    pop ax
    pop es
    pop ds
    jc @@ex
    mov al,@@buffer
    cbw
    sub ax,'0'
    cmp ax,0
    jl @@m
    cmp ax,@@ax
    jg @@m
    clc
@@ex:   mov sp,bp
    pop bp
    ret
    endp
    
    
algorithm   proc
locals @@
@@ibuf  equ [bp+6]
@@obuf  equ [bp+8]
local a:word
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cx,0ffffh
    mov di,@@ibuf
    xor al,al
    repne scasb
    neg cx
    dec cx
    dec cx
    jcxz @@ex2
    cmp cx,4095
    jbe @@m1
    stc
    jmp short @@ex2
@@m1:   mov di,@@ibuf
    mov al,10
    xor bx,bx
@@m2:   push di
    inc bx
    repne scasb
    cmp byte ptr [di-2],13
    jne @@er
    cmp byte ptr [di-1],10
    jne @@er
    jcxz @@m3
    jmp @@m2
    @@m3:  mov cx, bx
    mov dx, bx
    lea bx, a
    @@m31:pop  ax
    mov [bx], ax
    inc bx
    inc bx
    loop @@m31
    mov cx, dx
    lea bx, a
@@m32:    push [bx]
inc bx
    inc bx
    loop @@m32
    mov cx,dx
    mov di,@@obuf
@@m4:   pop si
@@m5:cld
    xor bx,bx
    xor dx,dx
@@m11: lodsb
    cmp al,13
    je @@m12
    cmp al,' '
    je @@m13
    cmp al, ','
    je @@m13
    cmp al, ';'
    je @@m13
    inc dl
    cmp dl, 10
    jne @@m11
    inc dh
    xor dl, dl
    jmp @@m11
@@ex2:jmp short @@ex

   @@er: jmp short @@er1
@@m12: mov bl,1
@@m13: cmp dx, 0
    je @@m14

    cmp bh, 1
    jne @@m16
    mov al, '.'
    stosb
    @@m16: or dh, dh
    je @@m15
    mov al, dh
    add al, '0'
    stosb
    @@m15: mov al, dl
    add al, '0'
    stosb
    xor dx, dx
    inc bh
    @@m14: cmp bl,1
    jne @@m11
    or bh, bh
    jne @@m17
    mov al,'0'
    stosb
    @@m17: mov al,13
    stosb 
    lodsb
    stosb
    cmp al,10
    jne @@m5
    loop @@m4
    xor al,al
    stosb
    
    

    
    clc
    jmp short @@ex
    @@er1:   shl bx,1
    add sp,bx
    stc
    @@ex:   pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
    end start
 

