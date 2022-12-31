global get_words
global compare_func
global sort

section .data
    delimiters dd 32, 44, 46, 10 ;Valorile pentru spatiu = 32, virgula = 44, punct = 46 si '\n' = 10
                                 ;in Ascii
section .text
    extern qsort
    extern strlen
    extern strcmp


;Functie de comparare ce trebuie sa sorteze cuvintele in primul rand dupa lungime
;si apoi, in caz de egalitate, lexicografic
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


sort:
    enter 0, 0
    ;Se stocheaza parametri in cei trei registri
    mov ebx, [ebp + 8]
    mov eax, [ebp + 12]
    mov ecx, [ebp + 16]
    ;Se face push pe stack parametrilor in ordine inversa pentru a putea fi apelati 
    ;corespunzator de functia qsort.
    push compare_func
    push ecx 
    push eax 
    push ebx
    call qsort ;Are loc apelarea functiei de sortare

    leave
    ret

get_words:
    enter 0, 0

    ; Se muta parametri transmisi (o parte din acestia) in registrii eax si ebx
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    xor ecx, ecx 
    ;Se parcurge intregul sir ce trebuie apoi impartit in cuvinte si se transforma 
    ;fiecare caracter ce face parte din vectorul de delimitatori in null (0x00)
    traverse:
        cmp [eax + ecx], byte 0x00
        je end_traverse
        xor edx, edx 
        mov edx, [eax + ecx]
        ;Verificarea pentru posibila egalitate cu fiecare delimitator in parte
        cmp dl, [delimiters + 0]
        je make_null
        cmp dl, [delimiters + 4]
        je make_null
        cmp dl, [delimiters + 8]
        je make_null
        cmp dl, [delimiters + 12]
        je make_null
        continue:
            add ecx, dword 1
            jmp traverse
    ;Caracterul curent este transformat in null
    make_null:
        mov [eax + ecx], byte 0x00
        jmp continue

    ;In urma acestei parcurgeri a sirului, acesta nu mai contine delimitatori ci insasi caracterele
    ;null prezinta punctele unde separarile trebuie facute. Astfel se va simula procesul functiei
    ;strtok. Se parcurge sirul si in momentul gasirii unui caracter null se verifica daca inaintea acestuia
    ;este un cuvant valid (diferit de null). Daca da, se adauga cuvantul, daca nu, procesul continua
    ;Intreaga parcurgere se opreste in momentul in care contorul cuvintelor gasite este egal cu cel al 
    ;numarului de cuvinte dat ca parametru
    end_traverse:
        xor ecx, ecx
        xor edi, edi 
        xor esi, esi 
        lea edx, [eax] ;Se copiaza adresa lui eax in registrul edx cu ajutorul lui LEA
        loop:
            cmp ecx, [ebp + 16] ;Se compara numarul de cuvinte gasite cu cel final
            je finish
            cmp [eax + esi], byte 0x00 ;Se verifica daca avem caracterul curent egal cu null, daca
            je try_word                ;da, se verifica existenta cuvantului anterior
            continue1:
                add esi, dword 1
                jmp loop 
        ;Se verifica daca se poate forma un cuvant anterior (primul caracter din edx este diferit de null)
        ;Acesta se adauga la lista de cuvinte daca este valabil
        try_word:
            cmp [edx + 0], byte 0x00
            je instruction
            mov [ebx + edi], edx ;Se muta in registrul ebx la adresa corespunzatoare noul cuvant gasit
            add ecx, dword 1     
            add edi, dword 4         ;Se avanseaza la urmatorul element din lista de cuvinte ce trebuie modificata  
            lea edx, [eax + esi + 1] ;Se muta in registrul edx noua adresa a pointerului ce este legat la 
            jmp continue1            ;caracterul imediat urmator celui gasit ca fiind null
            
        ;Cazul in care cuvantul nu este corect, caz in care doar adresa registrului edx este schimbata
        instruction:                
            lea edx, [eax + esi + 1]
            jmp continue1

finish:
    leave
    ret
