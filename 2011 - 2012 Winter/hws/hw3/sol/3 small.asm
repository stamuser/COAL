; small.asm
;------------------------------------------------
;	Homework 3
;
;	Students:
;				Evgeny Volodarsky, ID 323748004
;				Ilya Efanov,       ID 326814720
;
;	Submission Date: 05/01/2012
;------------------------------------------------
;
.MODEL SMALL
.CODE
.386
;
;	extern void polydiv( long int result[N], long int *rem, long int src[N], int n, long int k )
;							[BP+4]				[BP+6]		   [BP+8]		[BP+10]   [BP+12]
;
_polydiv PROC NEAR
  PUBLIC _polydiv
	PUSH BP									; Preserve BP
	MOV BP , SP							   	; Set BP to point to parameter area
	PUSH SI									; Preserve SI
	PUSH DI									; Preserve DI
;
	MOV SI , [BP+8]							; SI = offset src[0]
	MOV DI , [BP+4]							; DI = offset result[0]
	MOV EAX , 0								; EAX = 0
	MOV CX , [BP+10]						; Set counter CX = n
	INC CX									; CX = n+1
	Loop1:									; This loop will fill the result array
		MOV [DI] , EAX						; result[i] = k*result[i-1] + src[i-1]
		MOV EAX , [BP+12]					; EAX = k
		MOV EBX , [DI]						; EBX = result[i]
		MUL EBX								; EDX:EAX = k*result[i] (We assuming that EDX=0)
		ADD EAX , [SI]						; EAX = k*result[i] + src[i]
		ADD DI , 4							; Set DI to point to the next member of result array (i++)
		ADD SI , 4							; Set SI to point to the next member of src array (i++)
		LOOP Loop1							; CX-- and continue Loop1 until CX>0
	MOV DI , [BP+6]							; DI = offset rem
	MOV [DI] , EAX							; rem = k*result[i-1] + src[i-1]
;
	POP DI									; Restore DI
	POP SI									; Restore SI
	POP BP									; Restore BP
	RET
_polydiv ENDP
END 