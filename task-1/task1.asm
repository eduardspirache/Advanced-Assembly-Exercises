%include "../io.mac"

section .text
	global sort
	extern printf
	
; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0
	
	mov edx, [ebp + 12]
	xor ecx, ecx
	mov ebx, dword 9999
find_head:
	cmp [edx + 8 * ecx], ebx
	jl lower_than_global

	jmp not_lower_than_global
	
	lower_than_global:
		mov ebx, [edx + 8 * ecx]
		mov eax, [ebp + 12]
		mov esi, ecx
		imul esi, 8
		add eax, esi

	not_lower_than_global:
	add ecx, dword 1
	cmp ecx, [ebp + 8]
	jl find_head

	push eax
	mov ebx, eax
;; eax is now the head and edx is the array
;; we store in esi the global minimum value (in this case, head value)
 	mov esi, ebx
 	xor ecx, ecx
iterate_once:
	push ecx
	push ebx
	;;;;;;;;;;; loop2 ;;;;;;;;;;;
	xor ebx, ebx
	mov edi, dword 9999 ;; the local minimum
	iterate_multiple_times:
		;; if current element is lower or equal than the global minimum, we skip it
		cmp [edx + 8 * ebx], esi
		jle next
		;; if current element is greater or equal than the local minimum, we skip it
		cmp [edx + 8 * ebx], edi
		jge next
		
		;; we want to find the next lowest element in the array (the local minimum),
		;; that is higher than global minimum
		mov edi, [edx + 8 * ebx] ;; min_node = node[ebx].val
		mov ecx, ebx
		;;;;

		next:
		;;;; loop increment ;;;;
		add ebx, dword 1
		cmp ebx, [ebp + 8]
		jl iterate_multiple_times

	;; we store the node found as the next minimum to make the previous node point to it
	push esi
	mov esi, ecx ;; esi = counter (ecx)
	imul esi, 8 ;; we multiply index by 8 esi = esi * 8
	mov ecx, [ebp + 12] ;; we move the array pointer in ecx
	add ecx, esi ;; we go to the node[index] ecx = array[index]
	pop esi

	;; we move the new global minimum in esi
	mov esi, edi
	;; the previous element is in eax and we make it point to the current minimum element (ecx)
	
	mov [eax + 4], ecx
	;; we make the previous element current minimum element (eax = ecx)
	mov eax, ecx
	;; if we have reached the first element again, we jump to finish to avoid a loop
	pop ebx
	cmp eax, ebx
	je finish

	finish:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop ecx
 	add ecx, dword 1
 	cmp ecx, [ebp + 8]
	jl iterate_once


	pop eax
	leave
	ret
