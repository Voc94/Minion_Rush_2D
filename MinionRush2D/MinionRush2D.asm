.386
.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern srand: proc
extern time: proc
extern rand:proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
colorconstant dd 0FF0000h
colorarraw dd 0FFC0CBh,0FFC00Fh,0FC9C54h,0FFE373h,0F0FEEFh
mode dd 0
obj1 dd 3
obj2 dd 3
obj3 dd 3
obj4 dd 3
obj5 dd 3
buffer dd 0.0
highscore dd 0
score DD 0
lane DD 2
laneRandoms DD -1,-1,-1,-1,-1
window_title DB "Minion Rush 2D",0
area_width EQU 640
area_height EQU 480
area DD 0
obj1_x DD -1
obj1_y DD area_height-area_height/5+32
obj2_x DD -1
obj2_y DD area_height-area_height/5+32
obj3_x DD -1
obj3_y DD area_height-area_height/5+32
obj4_x DD -1
obj4_y DD area_height-area_height/5+32
obj5_x DD -1
obj5_y DD area_height-area_height/5+32
counter DD 0 ; numara evenimentele de tip timer
tryagain DD 0
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
difficulty_x EQU 280
easy_y EQU 100
hard_y EQU 380
symbol_width EQU 10
symbol_height EQU 20
sprite_width EQU 32
sprite_height EQU 32
include digits.inc
include letters.inc
include sprites.inc
screen DD 0
difficulty DD 0
position DD area_width/2-10
.code

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_sprite proc
	push ebp
	mov ebp,esp
	pusha
	lea esi, sprites
	draw_sprite:
	mov eax,[ebp+arg1]
	mov ebx, sprite_width
	mul ebx
	mov ebx, sprite_height
	mul ebx
	add esi, eax
	mov ecx, sprite_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, sprite_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, sprite_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_background
	cmp byte ptr [esi],2
	je simbol_pixel_brick
	cmp byte ptr [esi],3
	je simbol_pixel_pantaloni
	cmp byte ptr [esi],4
	je simbol_pixel_bluza
	cmp byte ptr [esi],5
	je simbol_pixel_cap
	cmp byte ptr [esi],6
	je simbol_pixel_par
	cmp byte ptr [esi],7
	je simbol_pixel_banana
	cmp byte ptr [esi],8
	je simbol_pixel_mustar
	cmp byte ptr[esi],11
	je simbol_pixel_rosu_inchis
	cmp byte ptr[esi],10
	je simbol_pixel_verde_inchis
	mov dword ptr [edi], 0h
	jmp simbol_pixel_next
simbol_pixel_background:	
	mov dword ptr [edi], 07CFC00h
	jmp simbol_pixel_next
simbol_pixel_brick:
	mov dword ptr [edi], 0ff7f50h
	jmp simbol_pixel_next
simbol_pixel_pantaloni:
	mov dword ptr [edi], 06ca0dch
	jmp simbol_pixel_next
simbol_pixel_bluza:
	mov dword ptr [edi], 0cc3333h
	jmp simbol_pixel_next
simbol_pixel_cap:
	mov dword ptr [edi], 0e5ccc9h
	jmp simbol_pixel_next
simbol_pixel_par:
	mov dword ptr [edi], 0cc7722h
	jmp simbol_pixel_next
simbol_pixel_mustar:
	mov dword ptr [edi],0ccdc39h
	jmp simbol_pixel_next
simbol_pixel_verde_inchis:
	mov dword ptr [edi],0265109h
	jmp simbol_pixel_next
	simbol_pixel_banana:
	mov dword ptr [edi], 0ffe135h
	jmp simbol_pixel_next
simbol_pixel_rosu_inchis:
	mov dword ptr [edi],0590215h
	jmp simbol_pixel_next
simbol_pixel_next:
	inc esi
	add edi, 4
	dec ecx
	cmp ecx,0
	jg bucla_simbol_coloane
	pop ecx
	dec ecx
	jnz bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_sprite endp


make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 07CFC00h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
make_background_macro macro start,area,len,color,jumpcolor
		local loop_paint,continua
		mov ecx,len
		mov eax,start
		add eax,area
		loop_paint:
		mov ebx,[eax]
		cmp ebx,jumpcolor
		je continua
		mov dword ptr [eax],color
		continua:
		add eax,4
		loop loop_paint
endm
; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
make_sprite_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sprite
	add esp, 16
endm
increase_obj macro obj_y,objtype
local afar
		cmp objtype,3
		je afar
		cmp obj_y,area_height-2*area_height/15
		jg afar
		add obj_y,area_height/12
		afar:
endm
character_movement macro
	local cantinuom,aici
			mov eax,[ebp+arg1]
			cmp eax,3
			jne cantinuom
			mov eax,[ebp+arg2]
			cmp eax,41h
			jne dreapta
			cmp position,area_width/5
			jle cantinuom
			make_sprite_macro 3,area,position,area_height-32
			sub position,area_width/5
			sub lane,1
			make_sprite_macro 0,area,position,area_height-32
			dreapta:
			cmp eax,44h
			jne leftarrow
			cmp position,area_width-area_width/5
			jge cantinuom
			make_sprite_macro 3,area,position,area_height-32
			add position,area_width/5
			add lane,1
			make_sprite_macro 0,area,position,area_height-32
			leftarrow:
			cmp eax,25h
			jne rightarrow
			cmp position,area_width/5
			jle cantinuom
			make_sprite_macro 3,area,position,area_height-32
			sub position,area_width/5
			sub lane,1
			make_sprite_macro 0,area,position,area_height-32
			rightarrow:
			cmp eax,27h
			jne cantinuom
			cmp position,area_width-area_width/5
			jge cantinuom
			make_sprite_macro 3,area,position,area_height-32
			add position,area_width/5
			add lane,1
			make_sprite_macro 0,area,position,area_height-32
			
			cantinuom:
endm
lane_score_macro macro y,laneRandom,objtype,lane
			local reset,zid
			cmp objtype,2
			jne zid
			mov eax,lane
			cmp eax,laneRandom
			jne reset
			add score,25
			jmp reset
			zid:
			mov eax,lane
			cmp eax,laneRandom
			jne reset
			mov screen,3
			reset:
			mov objtype,3
			mov y,48
			mov laneRandom,-1
endm
random_width macro x,y,objtype,laneRandom,laneRandoms
			local e_4,zid
			push eax
			call rand
			add esp,4 
			mov ebx,111b
			and eax,ebx
			cmp eax,4
			je e_4
			mov ebx,11b
			and eax,ebx
			e_4:
			mov laneRandom,eax
			mov ebx,area_width/5
			mul ebx
			add eax,48
			mov x,eax
			push eax
			call rand
			add esp,4
			mov ebx,1b
			and eax,ebx
			add eax,1
			mov y,48
			mov objtype,eax
			endm
line_horizontal macro x,y,len,color
local bucla_linie
	mov eax,y ; EAX = y
	mov ebx,area_width
	mul ebx	; EBX= y*area_width
	add eax,x; EAX= y*area_width+x
	shl eax,2 ;(EAX= y*area_width+x)*4
	add EAX,area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax,4
	loop bucla_linie
endm
line_vertical macro x,y,len,color
local bucla_linie_jos,bucla_linie_sus
	mov eax,y ; EAX = y
	mov ebx,area_width
	mul ebx	; EBX= y*area_width
	add eax,x; EAX= y*area_width+x
	shl eax,2 ;(EAX= y*area_width+x)*4
	add EAX,area
	mov ecx,len
bucla_linie_sus:
	mov dword ptr[eax], color
	add eax,area_width*4
	loop bucla_linie_sus
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax,area_width
	mov ecx,area_height
	mul ecx
	mov ecx,eax
	mov eax,area
	sub eax,4
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	mov eax,[ebp+arg2]
	cmp eax,1Bh
	jne aici
	mov score,0
	mov counter,0
	mov obj1,3
	mov obj2,3
	mov obj3,3
	mov obj4,3
	mov obj5,3
	mov screen,0
	aici:
	cmp screen,0
	je difficulty_select
	cmp screen,1
	je start_press
	cmp screen,2
	je minion_rush
	cmp screen,3
	je try_again
	cmp screen,4
	je the_end
			;0-select difficulty
			;1-start
			;2-minion rush
			;3-try again& show high score
difficulty_select:
		make_background_macro 0,area,area_height*area_width/2,07CFC00h,0
		make_text_macro 'E',area,difficulty_x,easy_y
		make_text_macro 'A',area,difficulty_x+10,easy_y
		make_text_macro 'S',area,difficulty_x+20,easy_y
		make_text_macro 'Y',area,difficulty_x+30,easy_y
		make_text_macro 'H',area,difficulty_x,hard_y
		make_text_macro 'A',area,difficulty_x+10,hard_y
		make_text_macro 'R',area,difficulty_x+20,hard_y
		make_text_macro 'D',area,difficulty_x+30,hard_y
		make_background_macro area_height*area_width/2*4,area,area_height*area_width/2,0FF0000h,0
		mov eax,[ebp+arg1]
		cmp eax, 2
		jz final_draw
		mov eax,[ebp+arg3]
		cmp eax,area_height/2
		jg Hard_Mode
		cmp eax,0
		jle final_draw
		Easy_Mode:
		mov mode,2
		inc screen
		jmp final_draw
		Hard_Mode:
		mov mode,1
		inc screen
		jmp final_draw
		
		
start_press:
			make_background_macro 0,area,area_height*area_width,07CFC00h,0
			make_text_macro 'S',area,300,240
			make_text_macro 'T',area,310,240
			make_text_macro 'A',area,320,240
			make_text_macro 'R',area,330,240
			make_text_macro 'T',area,340,240
			
			make_text_macro 'U',area,200,380
			make_text_macro 'S',area,210,380
			make_text_macro 'E',area,220,380
			make_text_macro ' ',area,230,380
			make_text_macro 'A',area,240,380
			make_text_macro ' ',area,250,380
			make_text_macro 'O',area,260,380
			make_text_macro 'R',area,270,380
			make_text_macro ' ',area,280,380
			make_text_macro 'D',area,290,380
			make_text_macro ' ',area,300,380
			make_text_macro 'O',area,310,380
			make_text_macro 'R',area,320,380
			make_text_macro ' ',area,330,380
			make_text_macro 'A',area,340,380
			make_text_macro 'R',area,350,380
			make_text_macro 'R',area,360,380
			make_text_macro 'O',area,370,380
			make_text_macro 'W',area,380,380
			make_text_macro 'S',area,390,380
			mov eax,[ebp+arg1]
			cmp eax,1
			jne final_draw
			inc screen
			jmp final_draw
minion_rush:
				cmp score,10025
				jl salt
				mov screen,4
				jmp aici
				salt:
			evt_timer:
			inc counter
			push 0
			call time                
			add esp, 4
			push eax                 
			call srand
			add esp, 4
			
			make_background_macro 0,area,area_height*area_width,07CFC00h,0
			make_sprite_macro 0,area,position,area_height-32
			line_vertical area_width/5,0,area_height,0
			line_vertical 2*area_width/5,0,area_height,0
			line_vertical 3*area_width/5,0,area_height,0
			line_vertical 4*area_width/5,0,area_height,0
			
			
			drawing_objects:
			cmp obj1,3
			je draw2
			make_sprite_macro obj1,area,obj1_x,obj1_y
			draw2:
			cmp obj2,3
			je draw3
			make_sprite_macro obj2,area,obj2_x,obj2_y
			draw3:
			cmp obj3,3
			je draw4
			make_sprite_macro obj3,area,obj3_x,obj3_y
			draw4:
			cmp obj4,3
			je draw5
			make_sprite_macro obj4,area,obj4_x,obj4_y
			draw5:
			
			mov eax,counter
			cmp eax,mode
			jne afisare_counter
			mov counter,0
			cmp obj1,3
			je spawn1
			cmp obj1_y,area_height-2*area_height/6+48
			jne incris1
			lane_score_macro obj1_y,[laneRandoms],obj1,lane
			incris1:
			increase_obj obj1_y,obj1
			jmp obj_2
			spawn1:
			random_width obj1_x,obj1_y,obj1,[laneRandoms],laneRandoms
			jmp afisare_counter
			
			obj_2:
			mov ecx,1
			cmp obj2,3
			je spawn2
			cmp obj2_y,area_height-2*area_height/6+48
			jne incris2
			lane_score_macro obj2_y,[laneRandoms+4],obj2,lane
			incris2:
			increase_obj obj2_y,obj2
			jmp obj_3
			spawn2:
			random_width obj2_x,obj2_y,obj2,[laneRandoms+4],laneRandoms
			jmp afisare_counter
			
			obj_3:
			mov ecx,2
			cmp obj3,3
			je spawn3
			cmp obj3_y,area_height-2*area_height/6+48
			jne incris3
			lane_score_macro obj3_y,[laneRandoms+8],obj3,lane
			incris3:
			increase_obj obj3_y,obj3
			jmp obj_4
			spawn3:
			random_width obj3_x,obj3_y,obj3,[laneRandoms+8],laneRandoms
			jmp afisare_counter
			
			obj_4:
			mov ecx,3
			cmp obj4,3
			je spawn4
			cmp obj4_y,area_height-2*area_height/6+48
			jne incris4
			lane_score_macro obj4_y,[laneRandoms+12],obj4,lane
			incris4:
			increase_obj obj4_y,obj4
			jmp afisare_counter
			spawn4:
			random_width obj4_x,obj4_y,obj4,[laneRandoms+12],laneRandoms
			jmp afisare_counter
			
			obj_5:
			mov ecx,4
			cmp obj5,3
			je spawn5
			cmp obj5_y,area_height-2*area_height/6+58
			jne incris5
			lane_score_macro obj5_y,[laneRandoms+16],obj5,lane
			incris5:
			increase_obj obj5_y,obj5
			jmp afisare_counter
			spawn5:
			random_width obj5_x,obj5_y,obj5,[laneRandoms+16],laneRandoms
			jmp afisare_counter
			
	afisare_counter:
				character_movement
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	
	mov ebx, 10
	mov eax, score
	; cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 50, 10
	; cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 40, 10
	; sute
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	jmp final_draw
try_again:
	make_text_macro 'T',area,270,160
	make_text_macro 'R',area,280,160
	make_text_macro 'Y',area,290,160
	make_text_macro ' ',area,300,160
	make_text_macro 'A',area,310,160
	make_text_macro 'G',area,320,160
	make_text_macro 'A',area,330,160
	make_text_macro 'I',area,340,160
	make_text_macro 'N',area,350,160
	
	make_text_macro 'S',area,270,200
	make_text_macro 'C',area,280,200
	make_text_macro 'O',area,290,200
	make_text_macro 'R',area,300,200
	make_text_macro 'E',area,310,200
	
	make_text_macro 'H',area,270,240
	make_text_macro 'I',area,280,240
	make_text_macro 'G',area,290,240
	make_text_macro 'H',area,300,240
	make_text_macro ' ',area,310,240
	make_text_macro 'S',area,320,240
	make_text_macro 'C',area,330,240
	make_text_macro 'O',area,340,240
	make_text_macro 'R',area,350,240
	make_text_macro 'E',area,360,240
	mov eax,score
	mov ebx,10
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 370, 200
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 360, 200
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 350, 200
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 340, 200
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 330, 200
	mov eax,highscore
	cmp eax,score
	jg continuez
	mov eax,score
	mov highscore,eax
	continuez:
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 420, 240
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 410, 240
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 400, 240
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 390, 240
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 380, 240
	make_background_macro 0,area,area_height*area_width,0FF0000h,0
	mov eax,[ebp+arg1]
	cmp eax,1
	jne final_draw
	mov score,0
	mov obj1,3
	mov obj2,3
	mov obj3,3
	mov obj4,3
	mov obj5,3
	mov screen,2
	jmp final_draw
	
	the_end:
	cmp counter,10
	jne horhor
			push 0
			call time                
			add esp, 4
			push eax                 
			call srand
			add esp, 4
			push eax
			call rand
			add esp,4
			xor colorconstant,eax
	horhor:
	inc counter
	make_text_macro 'T',area,270,240
	make_text_macro 'H',area,280,240
	make_text_macro 'E',area,290,240
	make_text_macro ' ',area,300,240
	make_text_macro 'E',area,310,240
	make_text_macro 'N',area,320,240
	make_text_macro 'D',area,330,240
		mov eax,area
		mov edx,area_height/8
		loop_linii:
		mov ecx,area_width*8
		loop_paint:
		mov ebx,[eax]
		cmp ebx,0
		je nare
		mov ebx,colorconstant
		mov dword ptr [eax],ebx
		nare:
		add eax,4
		loop loop_paint
		; cmp colorconstant,0FFFFFFh
		; asp:
		add colorconstant,0FF0000h
		jmp niext
		niext:
		dec edx
		cmp edx,0
		jne loop_linii
			mov eax,[ebp+arg1]
			cmp eax,1
			jne final_draw
			mov score,0
			mov obj1,3
			mov obj2,3
			mov obj3,3
			mov obj4,3
			mov obj5,3
			mov counter,0
			mov screen,0
		jmp final_draw
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
