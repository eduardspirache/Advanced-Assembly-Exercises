%include "../io.mac"

section .text
	global cmmmc
	extern printf

;; int cmmmc(int a, int b)
;
;; calculate least common multiple fow 2 numbers, a and b


;; Equivalent C program
; maximum number between n1 and n2 is stored in max
;     max = (n1 > n2) ? n1 : n2;
;
;     while (1) {
;         if (max % n1 == 0 && max % n2 == 0) {
;             printf("The LCM of %d and %d is %d.", n1, n2, max);
;             break;
;         }
;         ++max;
;     }
;     return 0;
; }

cmmmc:
	
	push eax
	pop ebx
	push edx
	pop ecx
	
	;; ebx = a
	;; ecx = b
	cmp ebx, ecx
	jge a_greater
	;; We want to store the greater number in eax
	push ecx
	pop eax
	jmp continue

	a_greater:
	push ebx
	pop eax
	
	; ;; Now ebx = a, ecx = b, eax = greatest of the two
	xor edi, edi
	continue:

	push eax
	xor edx, edx
	div ebx
	cmp edx, dword 0
	jne loop
	
	xor edx, edx
	pop eax
	
	push eax
	div ecx
	cmp edx, dword 0
	je finish

	loop:
	pop eax
	add eax, dword 1
	jmp continue
	pop eax
	finish:
	pop eax
	ret
