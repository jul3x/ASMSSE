        section .text
        global start, step
        extern applyCol, malloc

start:
        push rbp
        mov rbp, rsp
        mov [width], rdi
        mov [height], rsi
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


step:
        push rbp
        push rbx
        push r12
        push r13
        push r14                    ; preserved registers

        mov rbp, rsp
        sub rsp, 8                  ; stack alignment
        xor rsi, rsi                ; TODO check if width is > 0
        call applyCol               ; applyCol(T, 0)

        xor r12, r12
        mov r12d, [width]           ; r12 = width
        xor r13, r13
        mov r13d, [height]
        imul r13, 4                 ; r13 = height * sizeof(float)
        mov r14, 1                  ; j = 1
        mov rbx, [matrix]           ; rbx = &M[0]
        jmp check_if_last_column
for_every_column:
        mov rdi, rbx
        mov rsi, r14
        call applyCol               ; applyCol(&M[j * height], j + 1)
        add rbx, r13                ; next column
        inc r14
check_if_last_column:
        cmp r14, r12
        jl for_every_column

        ; copy data from temp_matrix to matrix
        mov rbx, [matrix]
        mov r14, [matrix_temp]
        xor r13, r13                ; i = 0
        imul r12d, [height]          ; r12 = height * width
        jmp check_if_last_cell_to_copy
copy_every_cell:
        lea rcx, [r14 + 4 * r13]    ; temp_matrix[i]
        mov ecx, [rcx]
        mov [rbx + 4 * r13], ecx    ; matrix[i] = temp_matrix[i]
        inc r13
check_if_last_cell_to_copy:
        cmp r13, r12
        jl copy_every_cell

        add rsp, 8                  ; cleanup
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret

        section .bss
width: resd 1
height: resd 1
weight: resd 1

matrix_temp: resq 1
matrix: resq 1
