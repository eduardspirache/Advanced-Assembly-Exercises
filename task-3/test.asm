compare_func:
    push ebp     
    mov ebp, esp 

    mov eax, [ebp + 8] ;Se muta in registrul eax pointerul spre sirul transmis ca prim parametru
    mov eax, [eax]     ;Se muta in eax valoarea sirului spre care acesta pointa inainte
    
    ;Registrul eax (primul sir) este impins pe stiva si se apeleaza functia externa strlen care 
    ;stocheaza lungimea sirului in eax
    push eax        
    call strlen
    ;Se impinge registrul edi pe stack deoarece valoarea acestuia trebuie pastrata si reasignata ulterior
    push edi 
    mov edi, eax ;Se muta dimensiunea primului sir in registrul edi

    ;Analog cum s-a procedat anterior, se fac calculele nexesare pentru cel de al doilea sir
    mov ecx, [ebp + 12] 
    mov ecx, [ecx]      

    push ecx 
    call strlen

    mov edx, edi
    mov edi, eax
    ;Odata salvate dimensiunile celor doua siruri in registrul edx, respectiv edi, ecestea sunt comparate
    ;si in functie de valoarea compararii se realizeaza diferite instructiuni te returnare 0 daca nu se vor
    ;interschimba cele doua siruri sau 1 daca se vor interschimba
    cmp edx, edi 
    jg instruction1
    cmp edx, edi 
    jl instruction2

    ;In cazul in care lungimea celor doua este egala, acestea vor fi sortate lexicografic. Valorile
    ;sirurilor sunt restituite.
    mov eax, [ebp + 8]
    mov eax, [eax]
    mov ecx, [ebp + 12]
    mov ecx, [ecx]
    
    ;Acestea sunt apoi inpinse pe stack si se apeleaza functia externa strcmp care va compara lexicografic
    ;cele doua siruri de caractere si va stoca in registrul eax valoarea functiei
    push ecx 
    push eax 
    call strcmp
    ;Cele doua valori sunt apoi scose de pe stack
    pop ecx 
    pop ecx
    jmp finish_cmp
    
    ;Instructiune pentru cazul in care primul sir are dimensiunea mai mare, cele doua trebuiesc interschimbate
    instruction1:
    mov eax, dword 1
    jmp finish_cmp
    ;Instructiune pentru cazul in care primul sir are dimensiune mai mica, cele doua nu trebuiesc interschimbate
    instruction2:
    mov eax, dword 0
    jmp finish_cmp

    finish_cmp:
    ;Se face restituirea registrului edi si de asemenea se scot valorile de pe stack
    pop edi 
    pop edi
    leave 
    ret