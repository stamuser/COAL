; hw4.asm
;------------------------------------------------
;	Homework 4
;
;	Students:
;				Evgeny Volodarsky, ID 323748004
;				Ilya Efanov,       ID 326814720
;
;	Submission Date: 07/02/2012
;------------------------------------------------
;
.MODEL LARGE
EXTRN _system:FAR
.STACK 100h
.CODE
	aCodes		DB 100 DUP (0)							; Ascii codes buffer
	sCodes		DB 100 DUP (0)							; Scan codes buffer
	Count		DW 0									; Counter of pressed buttons
	Orig_isr	DD ?									; Original ISR
	Out_Str		DB 'echo (   ,   )>>recky.txt',0		; String for system() function
	Tmp			DB 0
	ten			DB 10
main:
;
;	My keyboard ISR
;
MyInt16h PROC NEAR
	PUSHF									; Preserve Flags
	CALL DWORD PTR Orig_isr					; Call original INT 16h
	MOV DI , Count							; DI = current value of counter
	MOV aCodes[DI] , AL						; Save ascii code
	MOV sCodes[DI] , AH						; Save scan code
	INC DI									; Counter++
	MOV Count , DI							; Update counter
	IRET
MyInt16h ENDP
;
;	extern void set_record_keys()
;
_set_record_keys PROC FAR
  PUBLIC _set_record_keys
	PUSH BP									; Preserve BP
	MOV BP,SP
	PUSH AX									; Preserve AX
	PUSH DS									; Preserve DS
	PUSH ES									; Preserve ES
	PUSH BX									; Preserve BX
	MOV AX , 0								; Set AX = 0
	MOV ES , AX								; Set ES = 0
	MOV AX , ES:[88]						; AX = original ISR offset
	MOV WORD PTR Orig_isr , AX				; Orig_isr = original ISR offset
	MOV AX , ES:[90]						; AX = original ISR segment
	MOV WORD PTR Orig_isr+2 , AX			; Orig_isr+2 = original ISR segment
;
	CLI										; Disable interupts
	MOV AX , 0								; Set AX = 0
	MOV ES , AX								; Set ES = 0
	MOV AX , offset MyInt16h				; AX = new ISR offset
	MOV ES:[88],AX							; Set new ISR offset
	MOV AX , SEG MyInt16h					; AX = new ISR segment
	MOV ES:[90] , AX						; Set new ISR segment
	STI										; Reenable interupts
;
	POP BX									; Restore BX
	POP ES									; Restore ES
	POP DS									; Restore DS
	POP AX									; Restore AX
	POP BP									; Restore BP
	RET	
_set_record_keys ENDP
;
;	extern void unset_record_keys()
;
_unset_record_keys PROC FAR
  PUBLIC _unset_record_keys
	MOV AX , 0								; Set AX = 0
	MOV ES , AX								; Set ES = 0
	CLI										; Disable interupts
	MOV AX , WORD PTR Orig_isr				; AX = original ISR offset
	MOV ES:[88] , AX						; Restore original ISR offset
	MOV AX , WORD PTR Orig_isr+2			; AX = original ISR segment
	MOV ES:[90] , AX						; Restore original ISR segment
	STI										; Reenable interupts
;
	MOV SI , 0								; Set SI to point to first code in sCodes and aCodes
loop1:
	MOV AL , aCodes[SI]						; AL = ascii code of pressed button
	MOV Tmp , AL							; Tmp = ascii code of pressed button
	MOV AL , sCodes[SI]						; AL = scan code of pressed button
	MOV CX , 3
	MOV DI , 8
	loop2:
		CBW									; AL -> AX
		DIV ten								; AL = AX/10 , AH = AX%10
		XOR DX , DX							; DX = 0
		MOV DL , AH
		ADD DL , 48							; DL => ascii code
		CMP DL , 57							; If DL > ascii code of 9
		JG Skip1							; Skip
		CMP DL , 48							; If DL < ascii code of 0
		JL Skip1							; Skip
		MOV Out_Str[DI] , DL				; Write DL to Out_Str
	Skip1:
		DEC DI								; DI--
		LOOP loop2
	MOV CX , 3
	CMP DI , 5
	JNE sys
	MOV DI , 12d
	MOV AL , Tmp
	JMP loop2
sys:
	MOV AX , SEG Out_Str					; AX = segment of Out_str
	PUSH AX									; Store it for system() function
	MOV AX , OFFSET Out_Str					; AX = offset of Out_str
	PUSH AX									; Store it for system() function
	CALL _system							; Call system() function with Out_str
	ADD SP , 4								; Free parameter space
	INC SI									; SI++
	CMP SI , Count							; Check whether the buffers are empty
	JL loop1								; If not, continue the loop
	RET
_unset_record_keys ENDP
END main 	
