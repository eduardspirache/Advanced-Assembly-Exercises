%include "../io.mac"

section .text
	global par
	extern printf

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
push byte 'E'

par:
	;; str_length = edx, char* str = eax
	xor ecx, ecx
for:
	cmp [eax + ecx], byte '('
	jne else
	
	push eax
	xor ebx, ebx
	pop ebx
	add ebx, ecx
	push ebx ;; we push on the stack the parantheses at position str[ecx]
	jmp continue

	else:
	;; If the stack is not empty, continue; else fail
	cmp esp, byte 'E'
	je fail
		
		stack_not_empty:
		pop ebx
		cmp [eax + ecx], byte ')'
		jne fail
		cmp ebx, '('
		je fail


	continue:
	add ecx, 1
	cmp ecx, edx
	jl for
	
	cmp esp, byte 'E'
	je fail
	
	push dword 1
	pop eax
	jmp end
	
	fail:
	push dword 0
	pop eax

	end:
	ret
