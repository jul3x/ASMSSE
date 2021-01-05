        section .text
        global start, step
        extern malloc, printf

start:
        push rbp
        mov rbp, rsp
        mov [width], rdi
        mov [height], rsi
        mov [matrix], rdx
        movss [weight], xmm0        ; init values
        imul rdi, rsi               ; size of matrix_temp
        imul rdi, 4                 ; sizeof(float) * size of matrix_temp
        call malloc
        mov [matrix_temp], rax      ; rax has new pointer
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
        xor rsi, rsi
        call apply_col              ; apply_col(T, 0)

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
        call apply_col               ; apply_col(&M[j * height], j + 1)
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

apply_col:
        push rbp
        sub rsp, 8                  ; stack alignment
        mov rbp, rsp                ; rdi = T[], rsi = row
        mov r8d, [height]
        imul esi, r8d               ; rsi = row * h
        mov rax, [matrix]
        mov rcx, [matrix_temp]
        movss xmm3, [weight]

        mov rdx, 1                  ; i = 1
        sub r8d, 1                  ; r8d = height - 1

        movlps xmm0, [rax + 4 * rsi]; xmm0 = [x, x, matrix[row * h + 1], matrix[row * h]]
        movhps xmm0, [rdi]          ; xmm0 = [T[1], T[0], matrix[row * h + 1], matrix[row * h]]
        movss xmm1, [minus_three_const] ; xmm1 = [x, x, x, -3]
        mulss xmm0, xmm1            ; xmm0 = [T[1], T[0], matrix[row * h + 1], - 3 * matrix[row * h]]
        haddps xmm0, xmm0
        haddps xmm0, xmm0           ; xmm0 = [x, x, x, diff]
        mulss xmm0, xmm3            ; xmm0 = [x, x, x, diff * weight]
        movss xmm1, [rax + 4 * rsi]
        addss xmm0, xmm1            ; xmm0 = [x, x, x, matrix[row * h] + diff * weight]
        movss [rcx + 4 * rsi], xmm0 ; matrix_temp[row * h] = new_value
        jmp check_if_last_cell_to_apply
apply_for_every_cell:
        inc rsi                     ; ++ptr

        movlps xmm0, [rax + 4 * rsi]     ; xmm0 = [x, x, matrix[row * h + 1], matrix[row * h]]
        movhps xmm0, [rdi + 4 * rdx - 4] ; xmm0 = [T[i], T[i-1], matrix[row * h + 1], matrix[row * h]]
BREAK_1:
        movss xmm1, [minus_five_const]   ; xmm1 = [x, x, x, -5]
        mulss xmm0, xmm1                 ; xmm0 = [T[i], T[i-1], matrix[row * h + 1], - 5 * matrix[row * h]]
BREAK_2:
        haddps xmm0, xmm0
        haddps xmm0, xmm0
BREAK_3:
        movss xmm2, [rdi + 4 * rdx + 4]  ; xmm2 = [x, x, x, T[i+1]]
BREAK_4:
        addss xmm2, [rax + 4 * rsi - 4]  ; xmm2 = [x, x, x, T[i+1] + matrix[row * h - 1]]
BREAK_5:
        addss xmm0, xmm2                ; xmm0 = [x, x, x, diff]
        mulss xmm0, xmm3                ; xmm0 = [x, x, x, diff * weight]
        movss xmm1, [rax + 4 * rsi]
        addss xmm0, xmm1                ; xmm0 = [x, x, x, matrix[row * h] + diff * weight]
        movss [rcx + 4 * rsi], xmm0     ; matrix_temp[row * h] = new_value

        inc rdx                     ; ++i
check_if_last_cell_to_apply:
        cmp edx, r8d
        jl apply_for_every_cell

        add rsp, 8                  ; cleanup
        pop rbp
        ret


        section .bss
width: resd 1
height: resd 1
weight: resd 1

matrix_temp: resq 1
matrix: resq 1

        section .data
minus_three_const   dd -3.0
minus_five_const    dd -5.0
format_string       db `%f\n`, 0