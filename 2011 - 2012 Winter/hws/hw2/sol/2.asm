; idtest.asm
;------------------------------------------------
;	Homework 2
;
;	Students:
;				Evgeny Volodarsky, ID 323748004
;				Ilya Efanov,       ID 326814720
;
;	Submission Date: 10/12/2011
;------------------------------------------------
;
.MODEL SMALL
.STACK 100h
.DATA
	WelcomeString	DB 'Enter potential ID number:', 13, 10, '$'
	idString		DB 13, 10, 'Answer: 000000000 is $'
	notString		DB 'not $'
	validString		DB 'a valid ID number', 13, 10, '$'
	IncorrectInput	DB 13, 10, 'Incorrect input', 13, 10, '$'
	Two				DB 2					; For checking parity
	Sum				DW 0					; For ID validation
	Ten				DB 10					; For ID validation
.CODE
main:
	MOV AX , @DATA							; DS can be written to only through a register
	MOV DS , AX								; Set DS to point to data segment
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET WelcomeString			; Set DS:DX to point to WelcomeString
	INT 21H									; Print WelcomeString
	MOV CX , 0								; Set CX = 0 for counting digits
	MOV SI , 18								; Set SI to point to last digit in idString
	MOV AH , 1								; Set "get input from keyboard" option for int 21h
	INT 21H									; Gets input from keyboard and save it in AL. The input is ASCII sign
inputLoop:
	CMP AL , '9'							; Compare given input (AL) with ascii code of '9'
	JA incorrect							; If it is bigger, the input is incorrect!
	CMP AL , '0'							; Compare given input (AL) with ascii code of '0'
	JB incorrect							; If it is smaller, the input is incorrect!
	MOV idString[SI] , AL					; Put digit to idString
	INC CX									; CX++
	SUB SI , CX								; SI = SI - CX
	CMP SI , 10								; Check whether 9 digits were already entered
	JB validation							; If they were, go to ID validation
	MOV AH , 1								; Set "get input from keyboard" option for int 21h
	INT 21H									; Gets input from keyboard and save it in AL. The input is ASCII sign
	CMP AL , 13								; Compare given input (AL) with ascii code of "Enter"
	JE validation							; If "Enter" was pressed, go to ID validation
	moveLoop:
		MOV BL , idString[SI+1]				; \ 
		MOV idString[SI] , BL				;  \ 
		INC SI								;	} Move all digits in idString one place to the left
		CMP SI , 18							;  /			( because we need to free last place for next digit )
		JB moveLoop							; /
	JMP inputLoop							; Continue inputLoop with the new entered input (AL)
validation:
	MOV SI , 10								; Set SI to point to first digit in idString
	validLoop:
		MOV AL , idString[SI]				; AL = current digit
		SUB AL , '0'						; Convert digit (char) to number
		CBW									; Convert AL to AX
		ADD Sum , AX						; Sum = Sum + AX
		INC SI								; SI++
		CMP SI , 18							; Check whether all digits were already added to Sum
		JA printResut						; If they were, exit the validLoop and print resut
		MOV AL , idString[SI]				; AL = current digit
		SUB AL , '0'						; Convert digit (char) to number
		MUL Two								; AX = AL * 2
		DIV Ten								; AL = AX / 10 , AH = AX mod 10
		ADD AL , AH							; AL = AL + AH
		CBW									; Convert AL to AX
		ADD Sum , AX						; Sum = Sum + AX
		INC SI								; SI++
		JMP validLoop						; Continue the validLoop
incorrect:
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET IncorrectInput			; Set DS:DX to point to IncorrectInput
	INT 21H									; Print IncorrectInput
	JMP terminate							; Skip printing result and go to the end
printResut:
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET idString				; Set DS:DX to point to idString
	INT 21H									; Print idString
	MOV AX , Sum							; Set AX = Sum for validation
	DIV Ten									; Check whether the Sum divided by 10
	CMP AH , 0								; Compare (Sum mod 10) with 0
	JE valid								; If Sum mod 10 = 0, the ID is valid
		MOV AH , 9							; Set print option for int 21h
		MOV DX , OFFSET notString			; Set DS:DX to point to notString
		INT 21H								; Print notString
	valid:
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET validString				; Set DS:DX to point to validString
	INT 21H									; Print validString
terminate:
	MOV AH , 4CH							; Set terminate option for int 21h
	INT 21H									; Terminate program
END main