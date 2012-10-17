; hex2dec.asm
;------------------------------------------------
;	Home work 1
;
;	Students:
;				Evgeny Volodarsky, ID 323748004
;				Ilya Efanov,       ID 326814720
;
;	Submission Date: 25/11/2011
;------------------------------------------------
;
.MODEL SMALL
.STACK 100h
.DATA
	WelcomeString	DB 'This program converts numbers from Hex to Decimal', 13, 10, 'Enter number up to FFFF:', 13, 10, '$'
	NewLine			DB 13, 10, '$'
	ResultString	DB '     H =        D', 13, 10, '$'
	IncorrectInput	DB 13, 10, 'Incorrect input', 13, 10, '$'
	Result			DW 0					; For decimal result number
	Multiplier		DW 4096					; 16^3 for converting hex to decimal
	Base			DW 16					; Hex base
	Ten				DW 10					; Decimal base
.CODE
main:
	MOV AX , @DATA							; DS can be written to only through a register
	MOV DS , AX								; Set DS to point to data segment
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET WelcomeString			; Set DS:DX to point to WelcomeString
	INT 21H									; Print WelcomeString
	MOV SI , 0								; Set SI = 0, to fill the ResultString
inputLoop:
		MOV AH , 1							; Set "get input from keyboard" option for int 21h
		INT 21H								; Gets input from keyboard and save it in AL. The input is ASCII sign
		CMP AL , 'f'						; Compare given input (AL) with ascii code of 'f'
		JG incorrect						; If it is bigger, the input is incorrect!
		CMP AL , 'a'						; Compare given input (AL) with ascii code of 'a'
		JGE smallLetter						; If 'a' <= input <= 'f' we have correct hex digit
		CMP AL , 'F'						; Compare given input (AL) with ascii code of 'F'
		JG incorrect						; If it is bigger, the input is incorrect!
		CMP AL , 'A'						; Compare given input (AL) with ascii code of 'A'
		JGE bigLetter						; If 'A' <= input <= 'F' we have correct hex digit
		CMP AL , '9'						; Compare given input (AL) with ascii code of '9'
		JG incorrect						; If it is bigger, the input is incorrect!
		CMP AL , '0'						; Compare given input (AL) with ascii code of '0'
		JGE digit							; If '0' <= input <= '9' we have correct hex digit
		JMP incorrect						; AL < ascii code of '0', the input is incorrect!
	smallLetter:
		MOV ResultString[SI] , AL			; Put hex digit to ResultString
		SUB AL , 87							; Convert letter to number
		JMP convertion						; Go to number conversion
	bigLetter:
		MOV ResultString[SI] , AL			; Put hex digit to ResultString
		SUB AL , 55							; Convert letter to number
		JMP convertion						; Go to number conversion
	digit:
		MOV ResultString[SI] , AL			; Put hex digit to ResultString
		SUB AL , '0'						; Convert digit (char) to number
	convertion:
		MOV AH , 0							; Set AH = 0 for multiplication
		MUL Multiplier						; Convert hex to decimal
		ADD Result , AX						; Update the result
		MOV AX , Multiplier					; Set AX = Multiplier
		DIV Base							; Decrease Multiplier ( Multiplier = Multiplier / 16 )
		MOV Multiplier , AX					; Update Multiplier
		INC SI								; Update SI ( SI = SI + 1 ) for the next loop
		CMP SI , 4							; Check whether SI >= 4 ( 4th input digit )
		JB inputLoop						; If it isn't, continue the inputLoop
; End of inputLoop		
	ADD SI , 10								; Set SI to point to the last decimal digit in ResultString
	MOV AX , Result							; AX = Result
outputLoop:
	MOV DX , 0								; Set DX = 0 for division
	DIV Ten									; AX = DX:AX / 10 , DX = DX:AX mod 10 (Last digit)
	ADD DX , '0'							; Convert number to ascii
	MOV ResultString[SI] , DL				; Put digit to ResultString
	DEC SI									; SI = SI - 1
	CMP AX , 0								; Check whether AX = 0
	JNE outputLoop							; If it isn't, continue the outputLoop
; End of outputLoop
	JMP printResut							; Go to printResut
incorrect:
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET IncorrectInput			; Set DS:DX to point to IncorrectInput
	INT 21H									; Print IncorrectInput
	JMP terminate							; Skip printing result and go to the end
printResut:
	MOV AH , 9								; Set print option for int 21h
	MOV DX , OFFSET NewLine					; Set DS:DX to point to NewLine
	INT 21H									; Print NewLine
	MOV SI , 0								; Set SI = 0, to check whether ResultString starts whith zeroes
	skipingZeroes:
		MOV BL , ResultString[SI]			; BL = ResultString[SI]
		INC SI								; Increase SI for the next loop
		CMP BL , '0'						; Compare whether ResultString[SI] = '0'
		JE skipingZeroes					; If it is, check next digit
	DEC SI									; Decrease SI ( SI = SI - 1 )
	CMP SI , 4								; Check whether all digits are zeroes
	JNE notAllZeroes						; If not, skip next line
	DEC SI									; If all digits are zeroes, print one
	notAllZeroes:
	MOV DX , OFFSET ResultString			; Set DS:DX to point to ResultString
	ADD DX , SI								; Increase DX to skip all first zeroes in output
	INT 21H									; Print ResultString
terminate:
	MOV AH,4CH								; Set terminate option for int 21h
	INT 21H									; Terminate program
END main