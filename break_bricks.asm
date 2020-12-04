;prvi domaci brick-breaker  

sseg segment stack 'STACK' 
    dw 64 dup(?)
sseg ends
 
dseg segment "DATA"

    END_GAME db "izgubili ste,",13,10," kliknite space za novu igru","$"
    WIN_GAME db "pobedili ste,",13,10,"kliknite space za novu igru","$"
    
    SCORE_TO_STRING db "$"
    SCORE dw 0
    LIVES dw 03h 
    LIVES_STRING db "lives:$"
    SCORE_STRING db "score:$"
    NUMBER_OF_BRICKS db 00fh 
    
    START dw 00h
    MENU_STRING db "Kliknite space",13,10," da bi ste zapoceli igricu",13,10,"i-levo, o-desno","$"
    WINDOW_WIDTH dw 140h           ; sirina prozora (320px) 
    WINDOW_HEIGHT dw 0c8h          ;visina prozora(200px) 
    
    TIME_AUX  db 0                 ; varijabla koju koristimo za proveru promene vremena
    
    BALL_ORIGINAL_X dw 0a0h        ;centar po horizontali
    BALL_ORIGINAL_Y dw 0aah        ; centar sto blizi donjoj strani prozora
    BALL_X dw 0a0h                 ;pozicija kolone loptice (x)
    BALL_Y dw 0aah                 ; pozicija reda loptice (y)
    BALL_SIZE dw 04h               ; velicina loptice(koliko piksela loptica ima u duzini i visini)
    BALL_VELOCITY_X dw 03h         ; horizontalna brzina loptice
    BALL_VELOCITY_Y dw -02h        ; vertyikalna brzina loptice
    BALL_COLOR db 00h
    
    PADDLE_X dw 08ch 
    PADDLE_Y dw 0beh
    PADDLE_WIDTH dw 23h
    PADDLE_HEIGHT dw 05H
    PADDLE_VELOCITY dw  05h
    
    ;vrednosti za sve kutije kao i varijabla koja nam govori da li je bilo kolizije
    
    BOX_WIDTH dw 31h
    BOX_HEIGHT dw 0ah
    BOX1_X dw 0ah
    BOX1_Y dw 14h
    BOX2_X dw 45h
    BOX2_Y dw 14h
    BOX3_X dw 80h
    BOX3_Y dw 14h
    BOX4_X dw 0bbh
    BOX4_Y dw 14h
    BOX5_X dw 0f6h
    BOX5_Y dw 14h
    BOX6_X dw 0ah
    BOX6_Y dw 32h
    BOX7_X dw 45h
    BOX7_Y dw 32h
    BOX8_X dw 80h
    BOX8_Y dw 32h
    BOX9_X dw 0bbh
    BOX9_Y dw 32h
    BOX10_X dw 0f6h
    BOX10_Y dw 32h
    BOX11_X dw 0ah
    BOX11_Y dw 50h
    BOX12_X dw 45h
    BOX12_Y dw 50h
    BOX13_X dw 80h
    BOX13_Y dw 50h
    BOX14_X dw 0bbh
    BOX14_Y dw 50h
    BOX15_X dw 0f6h
    BOX15_Y dw 50h

    BOX1_COLLISION dw 00h
    BOX2_COLLISION dw 00h
    BOX3_COLLISION dw 00h
    BOX4_COLLISION dw 00h
    BOX5_COLLISION dw 00h
    BOX6_COLLISION dw 00h
    BOX7_COLLISION dw 00h
    BOX8_COLLISION dw 00h
    BOX9_COLLISION dw 00h
    BOX10_COLLISION dw 00h
    BOX11_COLLISION dw 00h
    BOX12_COLLISION dw 00h
    BOX13_COLLISION dw 00h
    BOX14_COLLISION dw 00h
    BOX15_COLLISION dw 00h
    
dseg ends


cseg segment "CODE"
     
    main proc FAR
            
    assume cs:cseg, ds:dseg, ss:sseg ; assume as code,data,stack (da bi prepoznalo promenljive)
    push ds                          ; push na stack ds registar
    sub ax,ax                        ; postavljamo 0 u ax
    push ax                          ; push na stack ax registar
    
    mov ax, dseg                     ; pamtimo na ax sve iz dseg
    mov ds, ax                       ; sa ax na ds(cuvanje)
    pop ax                           ; skidamo ax sa steka
    pop dx                           ; skidamo dx sa steka

    call clear_screen
    
    CHECK_TIME:
        mov ah, 2ch                  ;uzimamo vreme sistema 
        int 21h                      ; ch=hour ,cl=minutes, dh = seconds , dl=1/100 seconds
        
        cmp dl,TIME_AUX
        je CHECK_TIME                ;ako je isto proveri opet,ako je razlicito izvrsi naredne funkcije    
        
        cmp START, 01h
        je start_game 
        
        call game_menu
        
        jmp CHECK_TIME
        
        start_game:
        
        cmp LIVES,00h
        je end_game_label
        
        cmp NUMBER_OF_BRICKS,00h
        je win_game_label
        
        mov TIME_AUX ,dl             ;apdejtujemo vreme
         
        call clear_screen
        mov dx, 00h
        call draw_box
        
        
         call move_ball  
         call draw_ball  
        
         call move_paddle
         call draw_paddle 
         call draw_score_lives
        
         
        
         
        jmp CHECK_TIME               ;nakon sto se izvrse funkcije opet skoci na proveru vremena
    
         end_game_label:
         call end_game_screen
         jmp CHECK_TIME 
        
         win_game_label:
         call win_game_screen
         jmp CHECK_TIME
         
        ret    
    main endp

reset_ball_position_2 proc near
    mov ax ,BALL_ORIGINAL_X
    mov BALL_X, ax
    
    mov ax ,BALL_ORIGINAL_Y
    mov BALL_Y,ax 
    
    mov BALL_VELOCITY_Y,-02h 

    ret
reset_ball_position_2 endp   
    
draw_score_lives proc 

         mov ah, 02
         mov bh, 00
         mov dl, 90h
         mov dh, 00
         int 10h
         
         MOV AH,09H
         LEA DX,LIVES_STRING
         INT 21H

         mov ax,LIVES    
         mov cx, 10
         
         loophere2:
            mov dx, 0
            div cx

            ; delimo ax/10 pri cemu u dx nam se nalazi ax%10, i pusamo ax na stek radi cuvanja

            push ax

            ; convertujemo dl to ascii
            add dl, '0'

            mov ah,2                     ; 2 u ah znaci da treba da printuje samo jedan karakter
            int 21h           


            pop ax                       ; vracamo ax
    

            cmp ax, 0                    ; u slucaju da je ax nula mozemo prekinuti petlju
            jnz loophere2
            
            
         MOV AH,09H
         LEA DX,SCORE_STRING
         INT 21H

                  
         mov ax,0ah  
         mov cx, 10
         
         
         
        lea si,SCORE_TO_STRING           ; izdvojena memorija za skladistenje score


        MOV AX,SCORE         
        MOV BX,10         
        ASC2:
                mov dx,0                ; cistimo dx, to jest postavljamo ga na nulu
                DIV BX                  ;DIV AX/10
                ADD DX,48               ;drugi nacin za postavljanje u ascii karakter
                dec si                  ;pamtimo ih (karaktere) ali u obrnutom smeru, redosledu
                mov [si],dl
                CMP AX,0            
                JZ EXTT             
                JMP ASC2            
        EXTT:
                mov ah,9                ; print string
                mov dx,si
                int 21h
                RET


    ret 
draw_score_lives endp


end_game_screen proc near

        call clear_screen
    
        MOV AH,09H
        LEA DX,END_GAME
        INT 21H
        
      
        mov ah,01h                    ;proveravamo da li je pritisnut neki taster na tastaturi,ako ne ne radi nista
        int 16h 
        
        
        jz  check_space_end   ; zf=1 dugme je stisnuto 
         

        mov ah,00h                    ;proveri koje je dugme stisnuto
        int 16h                       ; u al registru ce biti ascii stisnutog tastera/space u nasem slucaju
        
        cmp al,20h                    ; provera da li je u al ascii space taster
        je space_clicked_end

        jmp   check_space_end 
        
        space_clicked_end:
            mov START,01h
            mov NUMBER_OF_BRICKS, 00Fh
            mov LIVES, 03h
            mov SCORE,00h
            MOV BOX1_COLLISION,00h
            MOV BOX2_COLLISION,00h
            MOV BOX3_COLLISION,00h
            MOV BOX4_COLLISION,00h
            MOV BOX5_COLLISION,00h
            MOV BOX6_COLLISION,00h
            MOV BOX7_COLLISION,00h
            MOV BOX8_COLLISION,00h
            MOV BOX9_COLLISION,00h
            MOV BOX10_COLLISION,00h
            MOV BOX11_COLLISION,00h
            MOV BOX12_COLLISION,00h
            MOV BOX13_COLLISION,00h
            MOV BOX14_COLLISION,00h
            MOV BOX15_COLLISION,00h
            call reset_ball_position_2
               
            check_space_end:    
            
    ret 
end_game_screen endp 



win_game_screen proc near 


         call clear_screen
            
         MOV AH,09H
         LEA DX,WIN_GAME
         INT 21H
      
      
         mov ah,01h                    ;proveravamo da li je pritisnut neki taster na tastaturi,ako ne ne radi nista
         int 16h 
        
        
         jz check_space_win            ; zf=1 taster je stisnut
         

         mov ah,00h                    ;proveri koji je taster stisnut
         int 16h                       ; u al registru ce biti ascii stisnutog tastera/space u nasem slucaju
        
         cmp al,20h                    ; provera da li je u al ascii space taster
         je space_clicked_win

         jmp  check_space_win    
        
         space_clicked_win:
            mov START,01h
            mov NUMBER_OF_BRICKS, 00Fh
            mov LIVES, 03h
            mov SCORE,00h
            MOV BOX1_COLLISION,00h
            MOV BOX2_COLLISION,00h
            MOV BOX3_COLLISION,00h
            MOV BOX4_COLLISION,00h
            MOV BOX5_COLLISION,00h
            MOV BOX6_COLLISION,00h
            MOV BOX7_COLLISION,00h
            MOV BOX8_COLLISION,00h
            MOV BOX9_COLLISION,00h
            MOV BOX10_COLLISION,00h
            MOV BOX11_COLLISION,00h
            MOV BOX12_COLLISION,00h
            MOV BOX13_COLLISION,00h
            MOV BOX14_COLLISION,00h
            MOV BOX15_COLLISION,00h
            call reset_ball_position_2
               
        check_space_win:    
    ret 
    
win_game_screen endp 


game_menu proc  near

    call clear_screen
    
    MOV AH,09H
    LEA DX,MENU_STRING
    INT 21H
      
      
        mov ah,01h                    ;proveravamo da li je pritisnut neki taster na tastaturi,ako ne ne radi nista
        int 16h 
        
        
        jz check_space                ; zf=1 taster je stisnut
         

        mov ah,00h                    ;proveri koje je dugme stisnuto
        int 16h                       ; u al registru ce biti ascii stisnutog tastera/space u nasem slucaju
        
        cmp al,20h                    ; provera da li je u al ascii space taster
        je space_clicked

        jmp  check_space    
        
        space_clicked:
            mov START,01h
            mov NUMBER_OF_BRICKS, 00Fh
            mov LIVES, 03h
            mov SCORE,00h
            MOV BOX1_COLLISION,00h
            MOV BOX2_COLLISION,00h
            MOV BOX3_COLLISION,00h
            MOV BOX4_COLLISION,00h
            MOV BOX5_COLLISION,00h
            MOV BOX6_COLLISION,00h
            MOV BOX7_COLLISION,00h
            MOV BOX8_COLLISION,00h
            MOV BOX9_COLLISION,00h
            MOV BOX10_COLLISION,00h
            MOV BOX11_COLLISION,00h
            MOV BOX12_COLLISION,00h
            MOV BOX13_COLLISION,00h
            MOV BOX14_COLLISION,00h
            MOV BOX15_COLLISION,00h
               
        check_space:    
        
    ret
game_menu endp
    
draw_box proc near
         mov cx, BOX1_X                    ; postavi kolonu (x koordinata)
         mov dx, BOX1_Y                    ; postavi red (y koordinata)
    
          mov ax, 01h
          cmp BOX1_COLLISION, ax
         je dont_draw_box1   
        
         
         draw_box_horizontal1:
    
          mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
          mov al,02h                       ; bira se boja piksela - plava
          mov bh,00h                       ; postavi broj strane
          int 10h                          ;izvrsi konfiguraciju
         
        
        
          inc cx                           ; cx=cx+1
          mov ax,cx                        ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
          sub ax, BOX1_X 
          cmp ax, BOX_WIDTH
          jng draw_box_horizontal1
        
          mov cx , BOX1_X                  ; resetujemo cx rigistar na pocetnu vrednost
          inc dx
        
          mov ax,dx                        ;cx- box_y > box_height ako jeste idemo u sledeci red ako nije nastavljamo kolonu
          sub ax,BOX1_Y
          cmp ax, BOX_HEIGHT
          jng draw_box_horizontal1
            
          dont_draw_box1:
         ;sada crtamo kutiju broj 2
                     mov cx, BOX2_X                     ; postavi kolonu (x koordinata)
                     mov dx, BOX2_Y                    ; postavi red (y koordinata)
                
                      mov ax, 01h
                      cmp BOX2_COLLISION, ax
                      je dont_draw_box2
                      
                     draw_box_horizontal2:
                
                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                      mov al,02h                       ; bira se boja piksela - plava
                      mov bh,00h                       ; postavi broj strane
                      int 10h                          ;izvrsi konfiguraciju
                     
                    
                    
                      inc cx                           ; cx=cx+1
                      mov ax,cx                        ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                      sub ax, BOX2_X 
                      cmp ax, BOX_WIDTH
                      jng draw_box_horizontal2
                    
                      mov cx , BOX2_X                  ; resetujemo cx rigistar na pocetnu vrednost
                      inc dx
                    
                      mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                      sub ax,BOX2_Y
                      cmp ax, BOX_HEIGHT
                      jng draw_box_horizontal2
                      
                      dont_draw_box2:
                      ; sada crtamo za kutiju 3 
                                 mov cx, BOX3_X                     ; postavi kolonu (x koordinata)
                                 mov dx, BOX3_Y                    ; postavi red (y koordinata)
                            
                                    mov ax, 01h
                                    cmp BOX3_COLLISION, ax
                                    je dont_draw_box3
                                    
                                 draw_box_horizontal3:
                            
                                  mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                  mov al,02h                       ; bira se boja piksela - plava
                                  mov bh,00h                       ; postavi broj strane
                                  int 10h                          ;izvrsi konfiguraciju
                                 
                                
                                
                                  inc cx                           ; cx=cx+1
                                  mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                  sub ax, BOX3_X 
                                  cmp ax, BOX_WIDTH
                                  jng draw_box_horizontal3
                                
                                  mov cx , BOX3_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                  inc dx
                                
                                  mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                  sub ax,BOX3_Y
                                  cmp ax, BOX_HEIGHT
                                  jng draw_box_horizontal3
                                  
                                  dont_draw_box3:
                                  ;sada crtamo kutiju broj 4
                                                        
                                                      mov cx, BOX4_X                     ; postavi kolonu (x koordinata)
                                                      mov dx, BOX4_Y                    ; postavi red (y koordinata)
                                                
                                                        mov ax, 01h
                                                        cmp BOX4_COLLISION, ax
                                                        je dont_draw_box4 
                                                        
                                                      draw_box_horizontal4:
                                                
                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                      mov al,02h                       ; bira se boja piksela - plava
                                                      mov bh,00h                       ; postavi broj strane
                                                      int 10h                          ;izvrsi konfiguraciju
                                                     
                                                    
                                                    
                                                      inc cx                           ; cx=cx+1
                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                      sub ax, BOX4_X 
                                                      cmp ax, BOX_WIDTH
                                                      jng draw_box_horizontal4
                                                    
                                                      mov cx , BOX4_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                      inc dx
                                                    
                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                      sub ax,BOX4_Y
                                                      cmp ax, BOX_HEIGHT
                                                      jng draw_box_horizontal4
                                                      
                                                      dont_draw_box4:
                                                                      ;sada crtamo kutiju broj 5
                                                                        
                                                                      mov cx, BOX5_X                     ; postavi kolonu (x koordinata)
                                                                      mov dx, BOX5_Y                    ; postavi red (y koordinata)
                                                                
                                                                        mov ax, 01h
                                                                        cmp BOX5_COLLISION, ax
                                                                        je dont_draw_box5  
                                                                        
                                                                      draw_box_horizontal5:
                                                                
                                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                                      mov al,02h                       ; bira se boja piksela - plava
                                                                      mov bh,00h                       ; postavi broj strane
                                                                      int 10h                          ;izvrsi konfiguraciju
                                                                     
                                                                    
                                                                    
                                                                      inc cx                           ; cx=cx+1
                                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                                      sub ax, BOX5_X 
                                                                      cmp ax, BOX_WIDTH
                                                                      jng draw_box_horizontal5
                                                                    
                                                                      mov cx , BOX5_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                                      inc dx
                                                                    
                                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                                      sub ax,BOX5_Y
                                                                      cmp ax, BOX_HEIGHT
                                                                      jng draw_box_horizontal5
                                                                      
                                                                      dont_draw_box5:
                                                                      
        ;sada crtamo kutiju broj 6
                                                                        
        mov cx, BOX6_X                     ; postavi kolonu (x koordinata)
        mov dx, BOX6_Y                    ; postavi red (y koordinata)
              
        mov ax, 01h
        cmp BOX6_COLLISION, ax
        je dont_draw_box6    
   
        
        draw_box_horizontal6:
                                                                
          mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
          mov al,06h                       ; bira se boja piksela - plava
          mov bh,00h                       ; postavi broj strane
          int 10h                          ;izvrsi konfiguraciju
                                                                     
                                                                    
                                                                    
         inc cx                           ; cx=cx+1
         mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
         sub ax, BOX6_X 
         cmp ax, BOX_WIDTH
         jng draw_box_horizontal6
                                                                    
         mov cx , BOX6_X                  ; resetujemo cx rigistar na pocetnu vrednost
         inc dx
                                                                    
         mov ax,dx                        ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
         sub ax,BOX6_Y
         cmp ax, BOX_HEIGHT
         jng draw_box_horizontal6
         
         dont_draw_box6:
         ;sada crtamo kutiju broj 7
                     mov cx, BOX7_X                     ; postavi kolonu (x koordinata)
                     mov dx, BOX7_Y                    ; postavi red (y koordinata)
                     
                     mov ax, 01h
                     cmp BOX7_COLLISION, ax
                     je dont_draw_box7    
                     
                     draw_box_horizontal7:
                
                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                      mov al,06h                       ; bira se boja piksela - plava
                      mov bh,00h                       ; postavi broj strane
                      int 10h                          ;izvrsi konfiguraciju
                     
                    
                    
                      inc cx                           ; cx=cx+1
                      mov ax,cx                        ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                      sub ax, BOX7_X 
                      cmp ax, BOX_WIDTH
                      jng draw_box_horizontal7
                    
                      mov cx , BOX7_X                  ; resetujemo cx rigistar na pocetnu vrednost
                      inc dx
                    
                      mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                      sub ax,BOX7_Y
                      cmp ax, BOX_HEIGHT
                      jng draw_box_horizontal7
                      
                      dont_draw_box7:
                      ; sada crtamo za kutiju 8
                                  mov cx, BOX8_X                     ; postavi kolonu (x koordinata)
                                  mov dx, BOX8_Y                    ; postavi red (y koordinata)
                            
                                 mov ax, 01h
                                 cmp BOX8_COLLISION, ax
                                 je dont_draw_box8
                                  
                                  draw_box_horizontal8:
                            
                                  mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                  mov al,06h                       ; bira se boja piksela - plava
                                  mov bh,00h                       ; postavi broj strane
                                  int 10h                          ;izvrsi konfiguraciju
                                 
                                
                                
                                  inc cx                           ; cx=cx+1
                                  mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                  sub ax, BOX8_X 
                                  cmp ax, BOX_WIDTH
                                  jng draw_box_horizontal8
                                
                                  mov cx , BOX8_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                  inc dx
                                
                                  mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                  sub ax,BOX8_Y
                                  cmp ax, BOX_HEIGHT
                                  jng draw_box_horizontal8
                                  
                                  dont_draw_box8:
                                  ;sada crtamo kutiju broj 9
                                                        
                                                      mov cx, BOX9_X                     ; postavi kolonu (x koordinata)
                                                      mov dx, BOX9_Y                    ; postavi red (y koordinata)

                                                      mov ax, 01h
                                                      cmp BOX9_COLLISION, ax
                                                      je dont_draw_box9  
                                                      
                                                      draw_box_horizontal9:
                                                
                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                      mov al,06h                       ; bira se boja piksela - plava
                                                      mov bh,00h                       ; postavi broj strane
                                                      int 10h                          ;izvrsi konfiguraciju
                                                     
                                                    
                                                    
                                                      inc cx                           ; cx=cx+1
                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                      sub ax, BOX9_X 
                                                      cmp ax, BOX_WIDTH
                                                      jng draw_box_horizontal9
                                                    
                                                      mov cx , BOX9_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                      inc dx
                                                    
                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                      sub ax,BOX9_Y
                                                      cmp ax, BOX_HEIGHT
                                                      jng draw_box_horizontal9
                                                      
                                                      dont_draw_box9:
                                                      ;sada crtamo kutiju broj 10
                                                                        
                                                                      mov cx, BOX10_X                     ; postavi kolonu (x koordinata)
                                                                      mov dx, BOX10_Y                    ; postavi red (y koordinata)
                                                                              
                                                                         mov ax, 01h
                                                                         cmp BOX10_COLLISION, ax
                                                                         je dont_draw_box10 
                                                                         
                                                                      draw_box_horizontal10:
                                                                
                                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                                      mov al,06h                       ; bira se boja piksela - plava
                                                                      mov bh,00h                       ; postavi broj strane
                                                                      int 10h                          ;izvrsi konfiguraciju
                                                                     
                                                                    
                                                                    
                                                                      inc cx                           ; cx=cx+1
                                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                                      sub ax, BOX10_X 
                                                                      cmp ax, BOX_WIDTH
                                                                      jng draw_box_horizontal10
                                                                    
                                                                      mov cx , BOX10_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                                      inc dx
                                                                    
                                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                                      sub ax,BOX10_Y
                                                                      cmp ax, BOX_HEIGHT
                                                                      jng draw_box_horizontal10   
                                                                      
                                                                      dont_draw_box10:
                                                   
        ;sada crtamo kutiju broj 11
                                                                        
        mov cx, BOX11_X                     ; postavi kolonu (x koordinata)
        mov dx, BOX11_Y                    ; postavi red (y koordinata)
               
         mov ax, 01h
         cmp BOX11_COLLISION, ax
         je dont_draw_box11        
        draw_box_horizontal11:
                                                                
          mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
          mov al,04h                       ; bira se boja piksela - plava
          mov bh,00h                       ; postavi broj strane
          int 10h                          ;izvrsi konfiguraciju
                                                                     
                                                                    
                                                                    
         inc cx                           ; cx=cx+1
         mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
         sub ax, BOX11_X 
         cmp ax, BOX_WIDTH
         jng draw_box_horizontal11
                                                                    
         mov cx , BOX11_X                  ; resetujemo cx rigistar na pocetnu vrednost
         inc dx
                                                                    
         mov ax,dx                        ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
         sub ax,BOX11_Y
         cmp ax, BOX_HEIGHT
         jng draw_box_horizontal11
         
         dont_draw_box11:
         ;sada crtamo kutiju broj 12
                     mov cx, BOX12_X                     ; postavi kolonu (x koordinata)
                     mov dx, BOX12_Y                    ; postavi red (y koordinata)
                     
                     mov ax, 01h
                     cmp BOX12_COLLISION, ax
                     je dont_draw_box12
                    
                     draw_box_horizontal12:
                
                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                      mov al,04h                       ; bira se boja piksela - plava
                      mov bh,00h                       ; postavi broj strane
                      int 10h                          ;izvrsi konfiguraciju
                     
                    
                    
                      inc cx                           ; cx=cx+1
                      mov ax,cx                        ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                      sub ax, BOX12_X 
                      cmp ax, BOX_WIDTH
                      jng draw_box_horizontal12
                    
                      mov cx , BOX12_X                  ; resetujemo cx rigistar na pocetnu vrednost
                      inc dx
                    
                      mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                      sub ax,BOX12_Y
                      cmp ax, BOX_HEIGHT
                      jng draw_box_horizontal12
                      
                      dont_draw_box12:
                      ; sada crtamo za kutiju 13
                                  mov cx, BOX13_X                     ; postavi kolonu (x koordinata)
                                  mov dx, BOX13_Y                    ; postavi red (y koordinata)
                                        
                                  mov ax, 01h
                                  cmp BOX13_COLLISION, ax
                                    je dont_draw_box13
                                    
                                  draw_box_horizontal13:
                            
                                  mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                  mov al,04h                       ; bira se boja piksela - plava
                                  mov bh,00h                       ; postavi broj strane
                                  int 10h                          ;izvrsi konfiguraciju
                                 
                                
                                
                                  inc cx                           ; cx=cx+1
                                  mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                  sub ax, BOX13_X 
                                  cmp ax, BOX_WIDTH
                                  jng draw_box_horizontal13
                                
                                  mov cx , BOX13_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                  inc dx
                                
                                  mov ax,dx                          ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                  sub ax,BOX13_Y
                                  cmp ax, BOX_HEIGHT
                                  jng draw_box_horizontal13
                                  
                                  dont_draw_box13:
                                  ;sada crtamo kutiju broj 14
                                                        
                                                      mov cx, BOX14_X                     ; postavi kolonu (x koordinata)
                                                      mov dx, BOX14_Y                    ; postavi red (y koordinata)
                                                      
                                                      
                                                      mov ax, 01h
                                                      cmp BOX14_COLLISION, ax
                                                      je dont_draw_box14          
                                                      
                                                        mov ax, 01h
                                                        cmp BOX14_COLLISION, ax
                                                        je dont_draw_box14
                                                        
                                                      draw_box_horizontal14:
                                                
                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                      mov al,04h                       ; bira se boja piksela - plava
                                                      mov bh,00h                       ; postavi broj strane
                                                      int 10h                          ;izvrsi konfiguraciju
                                                     
                                                    
                                                    
                                                      inc cx                           ; cx=cx+1
                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                      sub ax, BOX14_X 
                                                      cmp ax, BOX_WIDTH
                                                      jng draw_box_horizontal14
                                                    
                                                      mov cx , BOX14_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                      inc dx
                                                    
                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                      sub ax,BOX14_Y
                                                      cmp ax, BOX_HEIGHT
                                                      jng draw_box_horizontal14
                                                      
                                                       dont_draw_box14:
                                                      ;sada crtamo kutiju broj 15
                                                                                        
                                                                      mov cx, BOX15_X                     ; postavi kolonu (x koordinata)
                                                                      mov dx, BOX15_Y                    ; postavi red (y koordinata)
                                                                      
                                                                      mov ax, 01h
                                                                      cmp BOX15_COLLISION, ax
                                                                      je dont_draw_box15       
                                                                      
                                                                      draw_box_horizontal15:
                                                                
                                                                      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
                                                                      mov al,04h                       ; bira se boja piksela - plava
                                                                      mov bh,00h                       ; postavi broj strane
                                                                      int 10h                          ;izvrsi konfiguraciju
                                                                     
                                                                    
                                                                    
                                                                      inc cx                           ; cx=cx+1
                                                                      mov ax,cx                       ;cx- box_x > box_width ako jeste idemo u sledeci red ako nije nastavljamo kolonu
                                                                      sub ax, BOX15_X 
                                                                      cmp ax, BOX_WIDTH
                                                                      jng draw_box_horizontal15
                                                                    
                                                                      mov cx , BOX15_X                  ; resetujemo cx rigistar na pocetnu vrednost
                                                                      inc dx
                                                                    
                                                                      mov ax,dx                         ; cx -box_y >box_height ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
                                                                      sub ax,BOX15_Y
                                                                      cmp ax, BOX_HEIGHT
                                                                      jng draw_box_horizontal15   
                                                       
                                                                      dont_draw_box15:               
        ret
        
        
draw_box  endp


move_ball proc near 

        mov ax, BALL_VELOCITY_X
        add BALL_X ,ax               ; ball_x = ball_x + velocity_x

        
        cmp BALL_X ,00h              ; ball_x < 0, ako ne onda imamo koliziju
        jl NEG_VELOCITY_X_COLOR_0
        
        mov ax,WINDOW_WIDTH          ; kolizija sa desne strane
        sub ax, BALL_SIZE
        cmp BALL_X ,ax
        jg NEG_VELOCITY_X_COLOR_1
        
        
        mov bx, BALL_VELOCITY_Y 
        add BALL_Y ,bx               ;ball_y = ball_y + velocity_y
        
        cmp BALL_Y ,00h              ; ball_y < 0, ako ne onda imamo koliziju
        jl NEG_VELOCITY_Y
        
        mov ax,WINDOW_HEIGHT         ;kolizija sa donje strane
        sub ax, BALL_SIZE
        cmp BALL_Y ,ax
        jg reset_position
        
        
        
        ; proveravamo da li se loptica sudara sa pokretnom plocom(paddle)
        ;pristup sa dve kutije i njihovim max i min kordinata x i y 
       ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
       ; BALL_X + BALL_SIZE > PADDLE_X && BALL_X < PADDLE_X + PADDLE_WIDTH && BALL_Y +BALL_SIZE > PADDLE_Y  && BALL_Y < PADDLE_Y + PADDLE_HEIGHT
       
        mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, PADDLE_X
        jng check_collision 
       
        mov ax,PADDLE_X
        add ax,PADDLE_WIDTH
        cmp BALL_X, ax
        jnl check_collision
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,PADDLE_Y
        jng check_collision
        
        mov ax, PADDLE_Y
        add ax,PADDLE_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision
        
        ;ako dodjemo dovde loptica se sudara za plocicom
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        ret                             ; izlazimo iz procedure 
        
        NEG_VELOCITY_X_COLOR_0: 
            neg BALL_VELOCITY_X        ;negiramo brzinu zbog kolizije
            mov BALL_COLOR,01h         ; zbog zamene boje pri koliziji
            ret
            
        NEG_VELOCITY_X_COLOR_1: 
            neg BALL_VELOCITY_X        ;negiramo brzinu zbog kolizije
            mov BALL_COLOR,00h         ; zbog zamene boje pri koliziji
            ret    
            
        NEG_VELOCITY_Y: 
            neg BALL_VELOCITY_Y        ;negiramo brzinu zbog kolizije
            mov BALL_COLOR,00h         ; zbog zaneme boje pri koliziji
            ret 
            
        reset_position:
            call reset_ball_position 
            ret    
            
        check_collision:
        
        ;proveravamo da li postoji kolizija sa nekim od blokova
        
        ;posmatramo blok(kutiju) 1 
        cmp BOX1_COLLISION, 01h
        je check_collision1
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX1_X
        jng check_collision1 
       
        mov ax,BOX1_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision1
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX1_Y
        jng check_collision1
        
        mov ax, BOX1_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision1

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS 
        add SCORE, 03h
        mov BOX1_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision1:
        
                ;posmatramo blok(kutiju) 2 
                cmp BOX2_COLLISION, 01h
        je check_collision2
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX2_X
        jng check_collision2 
       
        mov ax,BOX2_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision2
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX2_Y
        jng check_collision2
        
        mov ax, BOX2_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision2

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS 
        add SCORE, 03h
        mov BOX2_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision2:
        
                ;posmatramo blok(kutiju) 3
                cmp BOX3_COLLISION, 01h
        je check_collision3
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX3_X
        jng check_collision3
       
        mov ax,BOX3_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision3
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX3_Y
        jng check_collision3
        
        mov ax, BOX3_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision3

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 03h
        mov BOX3_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision3:
        
                ;posmatramo blok(kutiju) 4
                cmp BOX4_COLLISION, 01h
        je check_collision4
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX4_X
        jng check_collision4
       
        mov ax,BOX4_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision4
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX4_Y
        jng check_collision4
        
        mov ax, BOX4_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision4

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 03h
        mov BOX4_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision4:
        
                ;posmatramo blok(kutiju) 5
        cmp BOX5_COLLISION, 01h
        je check_collision5
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX5_X
        jng check_collision5
       
        mov ax,BOX5_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision5
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX5_Y
        jng check_collision5
        
        mov ax, BOX5_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision5

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 03h
        mov BOX5_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision5:
        
                ;posmatramo blok(kutiju) 6
                cmp BOX6_COLLISION, 01h
                je check_collision6
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX6_X
        jng check_collision6
       
        mov ax,BOX6_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision6
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX6_Y
        jng check_collision6
        
        mov ax, BOX6_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision6

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 02h
        mov BOX6_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision6:
        
                ;posmatramo blok(kutiju) 7
                cmp BOX7_COLLISION, 01h
                je check_collision7
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX7_X
        jng check_collision7 
       
        mov ax,BOX7_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision7
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX7_Y
        jng check_collision7
        
        mov ax, BOX7_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision7

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 02h
        mov BOX7_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision7:
        
                ;posmatramo blok(kutiju) 8 
                cmp BOX8_COLLISION, 01h
                je check_collision8
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX8_X
        jng check_collision8 
       
        mov ax,BOX8_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision8
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX8_Y
        jng check_collision8
        
        mov ax, BOX8_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision8

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 02h
        mov BOX8_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision8:
        
                ;posmatramo blok(kutiju) 9
                cmp BOX9_COLLISION, 01h
                je check_collision9
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX9_X
        jng check_collision9
       
        mov ax,BOX9_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision9
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX9_Y
        jng check_collision9
        
        mov ax, BOX9_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision9

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 02h
        mov BOX9_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision9:
        
                ;posmatramo blok(kutiju) 10
                cmp BOX10_COLLISION, 01h
        je check_collision10
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX10_X
        jng check_collision10 
       
        mov ax,BOX10_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision10
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX10_Y
        jng check_collision10
        
        mov ax, BOX10_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision10

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 02h
        mov BOX10_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision10:
        
                ;posmatramo blok(kutiju) 11
                cmp BOX11_COLLISION, 01h
                je check_collision11
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX11_X
        jng check_collision11 
       
        mov ax,BOX11_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision11
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX11_Y
        jng check_collision11
        
        mov ax, BOX11_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision11

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 01h
        mov BOX11_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision11:
        
                ;posmatramo blok(kutiju) 12
                cmp BOX12_COLLISION, 01h
        je check_collision12
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX12_X
        jng check_collision12 
       
        mov ax,BOX12_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision12
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX12_Y
        jng check_collision12
        
        mov ax, BOX12_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision12

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 01h
        mov BOX12_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision12:
        
                ;posmatramo blok(kutiju) 13
                cmp BOX13_COLLISION, 01h
        je check_collision13
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX13_X
        jng check_collision13 
       
        mov ax,BOX13_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision13
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX13_Y
        jng check_collision13
        
        mov ax, BOX15_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision13

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 01h
        mov BOX13_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision13:
        
                ;posmatramo blok(kutiju) 14
                cmp BOX14_COLLISION, 01h
        je check_collision14
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX14_X
        jng check_collision14 
       
        mov ax,BOX14_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision14
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX14_Y
        jng check_collision14
        
        mov ax, BOX14_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision14

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 01h
        mov BOX14_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision14:
        
                ;posmatramo blok(kutiju) 15
        cmp BOX15_COLLISION, 01h
        je check_collision15
         mov ax, BALL_X
        add ax, BALL_SIZE
        cmp ax, BOX15_X
        jng check_collision15
       
        mov ax,BOX15_X
        add ax,BOX_WIDTH
        cmp BALL_X, ax
        jnl check_collision15
        
        mov ax, BALL_Y 
        add ax,BALL_SIZE
        cmp ax ,BOX15_Y
        jng check_collision15
        
        mov ax, BOX15_Y
        add ax,BOX_HEIGHT
        cmp BALL_Y, ax
        jnl check_collision15

        
        neg BALL_VELOCITY_Y             ; menjamo vertikalnu brzinu loptice
        dec NUMBER_OF_BRICKS
        add SCORE, 01h
        mov BOX15_COLLISION, 01h
        ret                             ; izlazimo iz procedure 
        
        check_collision15:
  ret
            
move_ball endp    
    
move_paddle proc near
        
        mov ah,01h                    ;proveravamo da li je pritisnut neki taster na tastaturi,ako ne ne radi nista
        int 16h 
        
        
        jz check_paddle_movement      ; zf=1 dugme je stisnuto 
         

        mov ah,00h                    ;proveri koje je dugme stisnuto
        int 16h                       ; u al registru ce biti ascii stisnutog tastera
        
        cmp al,6fh                    ; provera da li je u al malo "o' kao stisnuti taster
        je move_paddle_right
        cmp al,4fh                    ; provera da li je u al veliko "O' kao stisnuti taster
        je move_paddle_right
        
        cmp al,69h                    ; provera da li je u al malo "i' kao stisnuti taster
        je move_paddle_left
        cmp al,49h                    ; provera da li je u al veliko "I' kao stisnuti taster
        je move_paddle_left
        
        jmp  check_paddle_movement    
                                      ; ret
                                      ;ako je "i' krecemo se levo

                                      ;ako je "o' krecemo se desno         

        move_paddle_right: 
            mov ax,PADDLE_VELOCITY  
            mov bx,PADDLE_X
            add bx,PADDLE_WIDTH
            cmp bx, 140h
            je check_paddle_movement 
            add PADDLE_X ,ax
            jmp check_paddle_movement 
            
        move_paddle_left:
            mov ax,PADDLE_VELOCITY     
            cmp PADDLE_X ,00h
            je check_paddle_movement
            sub PADDLE_X ,ax
            jmp check_paddle_movement
            
        check_paddle_movement:    
        
        ret
        
move_paddle endp

reset_ball_position proc 
    mov ax ,BALL_ORIGINAL_X
    mov BALL_X, ax
    
    mov ax ,BALL_ORIGINAL_Y
    mov BALL_Y,ax 
    
    mov BALL_VELOCITY_Y,-02h 
    dec LIVES
    
    ret
reset_ball_position endp


draw_ball proc near                    ; procedura za crtanje loptice
    
    mov cx, BALL_X                     ; postavi kolonu (x koordinata)
    mov dx, BALL_Y                     ; postavi red (y koordinata)
    
    draw_ball_horizontal:
    
    
     cmp BALL_COLOR,01h                ; proveravamo da li ce promeniti boju ako smo promenili vrednost u ball_color
     jz first_color
      mov ah,0ch                       ; podesi konfiguraciju za ispis piksela
      mov al,04h                       ; bira se boja piksela - crvena
      mov bh,00h                       ; postavi broj strane
      int 10h                          ;izvrsi konfiguraciju
     
    
    
     inc cx                           ; cx=cx+1
     mov ax,cx                        ;cx- ball_x > ball_size ako jeste idemo u sledeci red ako nije nastavljamo kolonu
     sub ax, BALL_X 
     cmp ax, BALL_SIZE
     jng draw_ball_horizontal
    
     mov cx , BALL_X                  ; resetujemo cx rigistar na pocetnu vrednost
     inc dx
    
     mov ax,dx                        ; cx -ball_y >ball_size ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
     sub ax,BALL_Y
     cmp ax, BALL_SIZE
     jng draw_ball_horizontal
        
    ret
    
     first_color: 
     
         draw_ball_horizontal_second:
         mov ah,0ch                   ; podesi konfiguraciju za ispis piksela
         mov al,05h                   ; bira se boja piksela - ljubicasta
         mov bh,00h                   ; postavi broj strane
         int 10h                      ;izvrsi konfiguraciju
         
             inc cx                   ; cx=cx+1
             mov ax,cx                ;cx- ball_x > ball_size ako jeste idemo u sledeci red ako nije nastavljamo kolonu
             sub ax, BALL_X 
             cmp ax, BALL_SIZE
             jng draw_ball_horizontal
                         
             mov cx , BALL_X          ; resetujemo cx rigistar na pocetnu vrednost
             inc dx
            
             mov ax,dx                ; cx -ball_y >ball_size ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
             sub ax,BALL_Y
             cmp ax, BALL_SIZE
             jng draw_ball_horizontal_second
         ret
         
draw_ball endp


    
draw_paddle proc near
         mov cx, PADDLE_X             ; postavi kolonu (x koordinata)
         mov dx, PADDLE_Y             ; postavi red (y koordinata)
         
         draw_paddle_horizontal:
             mov ah,0ch               ; podesi konfiguraciju za ispis piksela
             mov al,09h               ; bira se boja piksela - plava
             mov bh,00h               ; postavi broj strane
             int 10h                  ;izvrsi konfiguraciju
             
             inc cx                   ; cx=cx+1
             mov ax,cx                ;cx- paddle_x > PADDLE_HEIGHT ako jeste idemo u sledeci red ako nije nastavljamo kolonu
             sub ax, PADDLE_X 
             cmp ax, PADDLE_WIDTH
             jng draw_paddle_horizontal
             
             mov cx , PADDLE_X        ; resetujemo cx rigistar na pocetnu vrednost
             inc dx
            
             mov ax,dx                ; cx -ball_y >ball_size ako jeste zavrsi proceduru ako nije nastavi sledecu liniju
             sub ax,PADDLE_Y
             cmp ax, PADDLE_HEIGHT
             jng draw_paddle_horizontal
        ret
draw_paddle endp


clear_screen proc near                ;procedura za brisanje ekrana

          mov ah,00h                  ;podesi konfiguraciju (video mod)
          mov al,13h 
          int 10h                     ; izvrsi konfiguraciju
            
          mov ah,0bh                  ;podesi konfiguraciju- boja pozadine-crna
          mov bh,00h 
          mov bl,00h                  ; biramo boju
          int 10h                     ;izvrsi konfiguraciju
          ret
          
clear_screen endp  

  
cseg ends
    end main 
