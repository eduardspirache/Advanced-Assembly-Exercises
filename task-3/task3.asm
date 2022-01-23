%include "../io.mac"

global get_words
global compare_func
global sort
global compare

section .text
    extern printf
    extern strtok
    extern qsort
    extern strlen
    extern strcmp

section .data
    separators db ' ,.', 10,0

;;compare(char *s1, char *s2)
compare:
    enter 0, 0
    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]

    mov eax, [eax]
    mov ecx, [ecx]

    ;; CALL 1 ;;
    push eax
    push ecx

    push eax
    call strlen
    add esp, 4
    mov ebx, eax ;; ebx = strlen(eax)

    pop ecx
    pop eax

    ;; CALL 2 ;;
    push eax
    push ecx

    push ecx
    call strlen
    add esp, 4
    mov edx, eax ;; edx = strlen(eax)

    pop ecx
    pop eax

    cmp ebx, edx
    jl lower

    cmp ebx, edx
    je equal

    ;; If ecx is lower than ebx, return ecx
    mov eax, dword 1
    jmp finish1

    equal:
    push eax
    push ecx
    call strcmp
    add esp, 8
    cmp eax, dword 0
    jg copy1
    mov eax, dword 1
    jmp finish1
    copy1:
    mov eax, dword 0
    jmp finish1

    lower:
    mov eax, dword 0

    finish1:
    leave
    ret
;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0
    mov ebx, [ebp + 8]
    mov eax, [ebp + 12]
    mov ecx, [ebp + 16]
    push compare
    push ecx
    push eax
    push ebx
    call qsort
    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    push separators
    mov ebx, [ebp + 8]
    push ebx
    call strtok
    add esp, dword 8

    mov ebx, [ebp + 12]
    mov [ebx + 0], eax

    xor ecx, ecx
    add ecx, dword 4

    while:
    push ecx
    push separators
    push 0x00
    call strtok
    add esp, dword 8
    pop ecx

    cmp eax, 0x00
    je finish

    mov [ebx + ecx], eax

    add ecx, dword 4
    jmp while
    
    finish:
    leave
    ret
