global expression
global term
global factor
global number 

number:
        push ebp
        mov ebp, esp

        ;Se salveaza parametrii, sirul in edx si pozitia din sir ce trebuie calculata in ecx
        mov edx, [ebp + 8] 
        mov ecx, [ebp + 12]

        xor esi, esi 

        ;Se construieste numarul format din caracterele consecutive intre 0 si 9
        traverse_digits:
                mov edi, [ecx]            ;Se salveaza valoarea pinterului ecx (pozitia efectiva) in edi apoi se compara 
                cmp [edx + edi], byte 48  ;cu valoarea caracterului '0' in ASCII (48). Daca valoarea este mai mare sau egala 
                jge test                  ;se face jump la test pentru a verifica daca este <= '9'
                jmp finish_number         ;In cazul in care caracterul curent este < '0' se incheie procesul
                
                ;Daca caracterul curent reprezinta o cifra se salveaza in subregistrul bl si se scade 48 pentru a obtine
                ;valoarea numerica corespunzatoare. Dupa acest pas, se adauga cifra la registrul esi prin metode cunoscute
                continue:
                        xor ebx, ebx 
                        mov bl, [edx + edi]  
                        sub bl, byte 48
                        imul esi, dword 10
                        add esi, ebx 
                        add [ecx], dword 1 ;Inscrementeaza pozitia in sir
                        jmp traverse_digits ;Continua cu urmatorul caracter
        test:
                cmp [edx + edi], byte 57
                jle continue
                jmp finish_number

finish_number:
        leave 
        ret ; Desi in mod normal functia returneaza registrul eax, se va folosi rezultatul stocat in registrul esi

factor:
        push    ebp
        mov     ebp, esp

        ;Se salveaza parametrii, sirul in edx si pozitia din sir ce trebuie calculata in ecx
        mov edx, [ebp + 8]
        mov ecx, [ebp + 12]

        xor edi, edi 

        ;Se verifica daca caracterul curent este cifra sau paranteza deschisa (
        mov esi, [ecx]
        cmp [edx + esi], byte 48
        jge case1               ;Caracterul este >= '0', caz in care se verifica daca este <= '9' in interiorul lui case1
        jmp case_parenthesis    ;Caracterul este < '0', caz in care trebuie sa fie paranteza

        case1:
                cmp [edx + esi], byte 57
                jle case_number         ;Caracterul este identificat ca cifra sau paranteza si se merge pe cazul corespunzator
                jmp case_parenthesis

        case_number:
                ;Se pun pe stiva parametri necesari pentru functia number in ordine inversa si apoi se apeleaza functia number
                push ecx
                push edx
                call number
                ;Numarul a fost calculat si este mutat in edi
                mov edi, esi
                jmp finish_factor ;Procesul se incheie deoarece intregul factor a fost calculat
        
        ;In cazul intalnirii unei paranteze deschise avem de a face cu o noua expresie ce alcatuieste acest factor. Aceasta
        ;trebuie calculata pentru a putea obtine factorul corespunzator
        case_parenthesis:
                add [ecx], dword 1 ;Se trece peste paranteza prin incrementarea valorii din ecx
                ;Se imping pe stiva parametrii corespunzatori apelarii functiei expression dupa care se apeleaza
                push ecx 
                push edx 
                call expression
                add [ecx], dword 1 ;Se trece peste paranteza inchisa )
                mov edi, eax       ;In urma expresiei factorul a fost calculat, valoarea acestuia fiind stocata in registrul eax
                                   ;Este apoi mutata in registrul edi care reprezinta parametrul folsit la iesirea acestei functii

finish_factor:
        leave
        ret


term:
        push    ebp
        mov     ebp, esp
        
        ;Se salveaza parametrii, sirul in edx si pozitia din sir ce trebuie calculata in ecx
        mov edx, [ebp + 8]
        mov ecx, [ebp + 12]

        xor ebx, ebx 

        ;Un termen este alcatuit din inmultirea sau impartirea a doi sau mai multi factori, astfel este necesara obtinerea
        ;tururor acestor factori si aplicarea operatiilor corespunzatoare intre acestia. Pentru acest lucru este nevoie de 
        ;o parcurgere a sirului pentru calcularea consecutiva a acestor factori 
        push ecx 
        push edx 
        call factor ;Se calculeaza primul factor, valoare ce se va afla in resgistrul edi care este apoi mutata in ebx

        mov ebx, edi 

        traverse1:
                mov esi, [ecx]
                cmp [edx + esi], byte 42     ;Daca caracterul ce urmeaza dupa factor este *, se merge pe cazul de multiplicare
                je multiply
                cmp [edx + esi], byte 47     ;Daca caracterul ce urmeaza dupa factor este /, se merge pe cazul de impartire
                je divide
                jmp finish_term  ;In cazul in care caracterul difera de * si /, procesul se incheie, rezultatul fiind stocat in ebx

        multiply:
                add [ecx], dword 1 ;Se trece pese caracterul * 
                push ebx           ;Se introduce pe stack valoarea lui ebx ce va fi preluata inapoi dupa apelul functiei factor
                push ecx           ;In acest mod ne asiguram ca nu se va pierde valoarea lui ebx
                push edx 
                call factor        ;Se apeleaza factor care stocheaza in edi urmatorul factor
                pop ebx 
                pop ebx 
                pop ebx            ;Prin cele trei pop-uri se ajunge la valoarea lui ebx initiala pe care o stocam din nou in ebx
                imul ebx, edi      ;Se inmulteste valoarea lui ebx cu edi
                jmp traverse1      ;Se continua traversarea prin sir
        divide:
                ;Analog ca in cazul interior
                add [ecx], dword 1
                push ebx
                push ecx 
                push edx 
                call factor     
                pop ebx 
                pop ebx 
                pop ebx 
                
                ;Se introduce valoarea lui edx pe stiva si apoi se face 0 cu xor deoarece impartirea cu idiv se face
                ;folosind registrii eax si edx. Din acest motiv edx trebuie salvat in prealabil
                push edx 
                xor edx, edx 

                ;Se foloseste metoda de impartire clasica cu idiv, rezultatul fiind stocat in eax
                push ebx
                push dword 1
                pop ebx 
                

                push edi
                pop esi
                
                pop eax 
                imul ebx
                idiv esi 
                ;Dupa impartire se restaureaza valoarea lui edx si se muta valoarea impartirii din registrul eax in ebx 
                ;deoarece ebx este registrul ce va stoca valoarea functiei term
                pop edx   
                mov ebx, eax 
                jmp traverse1 ;Se continua traversarea prin sirul de caractere

finish_term:
        leave
        ret


expression:
        push    ebp
        mov     ebp, esp
        
        ;Se salveaza parametrii, sirul in edx si pozitia din sir ce trebuie calculata in ecx
        mov edx, [ebp + 8]
        mov ecx, [ebp + 12]

        xor eax, eax 

        ;O expresie este alcatuita din adunarea sau diferenta a doi sau mai multi termeni, astfel este necesara obtinerea
        ;tururor acestor termeni si aplicarea operatiilor corespunzatoare intre acestia. Pentru acest lucru este nevoie de 
        ;o parcurgere a sirului pentru calcularea consecutiva a termenilor
        push ecx 
        push edx 
        call term ;Se calculeaza primul termen, valoare ce se va afla in resgistrul ebx care este apoi mutata in eax
        mov eax, ebx 
        
        traverse:
                 mov esi, [ecx]
                 cmp [edx + esi], byte 43  ;Daca caracterul ce urmeaza dupa termen este +, se merge pe cazul de insumare
                 je adding
                 cmp [edx + esi], byte 45  ;Daca caracterul ce urmeaza dupa termen este -, se merge pe cazul de multiplicare
                 je substracting
                 jmp finish_expression  ;In cazul in care caracterul difera de + si -, procesul se incheie, rezultatul fiind stocat in eax

        adding:
                add [ecx], dword 1   ;Se trece peste caracterul +
                ;Se salveaza valoarea registrului eax pe stack pentru a fi preluat la finalul apelarii functiei term si
                ;sunt adaugati pe stack si parametrii corespunzatori pentru apelarea functiei term, urmata de apelarea acesteia
                push eax 
                push ecx
                push edx 
                call term
                ;Cu ajutorul celor trei pop-uri valoarea lui eax este restaurata
                pop eax 
                pop eax 
                pop eax  
                add eax, ebx ;La eax se adauga valoarea urmatorului termen obtinut
                jmp traverse ;Se continua traversarea sirului de caractere

        ;Procesul este identic cu cel din cadrul aditiei cu exceptia scaderii in locul adunarii intre cei doi termeni
        substracting:
                add [ecx], dword 1
                push eax
                push ecx 
                push edx 
                call term
                pop eax
                pop eax 
                pop eax 
                sub eax, ebx 
                jmp traverse

finish_expression: ;In final, rezultatul expresiei curente va fi stocat in eax, regsitru ce este returnat si in programul principal
        leave
        ret
