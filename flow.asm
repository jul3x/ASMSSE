        section .text
        global start
        extern malloc

start:
        push rbp
        mov rbp, rsp
        mov [width], rdi
        mov [heigth], rsi
        mov [matrix], rdx
        movss [weight], xmm0        ; init values
        imul rdi, rsi               ; size of matrix_temp
        imul rdi, 4                 ; sizeof(float) * size of matrix_temp

        push rdi                    ; malloc for temp matrix
        call malloc
        mov [matrix_temp], rax      ; rax has new pointer
        pop rdi

        pop rbp
        ret


        section .bss
width: resd 1
heigth: resd 1
weight: resd 1

matrix_temp: resq 1
matrix: resq 1
