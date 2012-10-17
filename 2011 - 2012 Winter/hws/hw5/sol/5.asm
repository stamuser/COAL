; hw5.asm
;------------------------------------------------
;	Homework 5
;
;	Students:
;				Evgeny Volodarsky, ID 323748004
;				Ilya Efanov,       ID 326814720
;
;	Submission Date: 07/02/2012
;------------------------------------------------
;
.MODEL SMALL
.DATA
Two		DD 2.0
Four	DD 4.0
Zero	DD 0.0
Temp	DQ 0.0
.CODE
.386
.387
;
; extern int fsolve_quadratic(float a, float b, float c, float *r1, float *i1, float *r2, float *i2);
;								[BP+4]	[BP+8]	[BP+12]	  [BP+16]	[BP+18]		[BP+20]		[BP+22]
;
_fsolve_quadratic PROC NEAR
PUBLIC _fsolve_quadratic
	PUSH BP							; Preserve BP
	MOV BP,SP						; Set BP to point to parameter area
;
	FLD DWORD PTR [BP+4]			; ST(0) = a
	FMUL Four						; ST(0) = 4*a
	FMUL DWORD PTR [BP+12]			; ST(0) = 4*a*c
	FLD DWORD PTR [BP+8]			; ST(0) = b , ST(1) = 4*a*c
	FMUL ST , ST(0)					; ST(0) = b^2 , ST(1) = 4*a*c
	FSUBRP ST(1) , ST				; ST(0) = b^2 - 4*a*c
	FCOM Zero						; Compare ( b^2 - 4*a*c ) with 0
	FSTSW AX						; Store comparison result in AX
	SAHF							; Store C3, C2, C0 in Flags register
	JAE Positive1					; If ( b^2 - 4*a*c ) >= 0 jump to Positive
		FCHS						; If not, change sign ( ST -> -ST )
		MOV AX , 0					; AX = 0 ( return value )
	Positive1:
	FSQRT							; ST(0) = sqrt( b^2 - 4*a*c )
	FLD DWORD PTR [BP+4]			; ST(0) = a , ST(1) = sqrt( b^2 - 4*a*c )
	FMUL Two						; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )
	FDIV ST(1) , ST					; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	FLD DWORD PTR [BP+8]			; ST(0) = b , ST(1) = 2*a , ST(2) = sqrt( b^2 - 4*a*c )/2a
	FDIVR							; ST(0) = b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	CMP AX , 0						; Compare AX with 0
	JE Complex1						; If AX =0, we have complex roots
		FST Temp					; Temp = b/2a
		FSUBR ST , ST(1)			; ST(0) = sqrt( b^2 - 4*a*c )/2a - b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+20]			; BX = offset r2
		FSTP DWORD PTR [BX]			; *r2 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		FLD Temp					; ST(0) = b/2a , ST(1) = -sqrt( b^2 - 4*a*c )/2a
		FSUB						; ST(0) = -sqrt( b^2 - 4*a*c )/2a - b/2a
		MOV BX , [BP+16]			; BX = offset r1
		FSTP DWORD PTR [BX]			; *r1 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FLD Zero					; ST(0) = 0.0
		MOV BX , [BP+18]			; BX = offset i1
		FST DWORD PTR [BX]			; *i1 = 0.0
		MOV BX , [BP+22]			; BX = offset i2
		FSTP DWORD PTR [BX]			; *i2 = 0.0
		MOV AX , 2					; AX = 2 ( return value )
		JMP SkipComplex1			; Skip calculations for complex roots
	Complex1:
		FCHS						; ST(0) = -b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+16]			; BX = offset r1
		FST DWORD PTR [BX]			; *r1 = -b/2a
		MOV BX , [BP+20]			; BX = offset r2
		FSTP DWORD PTR [BX]			; *r2 = -b/2a
		MOV BX , [BP+22]			; BX = offset i2
		FST DWORD PTR [BX]			; *i2 = sqrt( b^2 - 4*a*c )/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+18]			; BX = offset i1
		FSTP DWORD PTR [BX]			; *i1 = -sqrt( b^2 - 4*a*c )/2a
SkipComplex1:
;
	POP BP							; Restore BP
	RET								; Return from routine
_fsolve_quadratic ENDP
;
; extern int dsolve_quadratic(double a, double b, double c, double *r1, double *i1, double *r2, double *i2);
;								[BP+4]	[BP+12]	  [BP+20]	  [BP+28]	[BP+30]		[BP+32]		[BP+34]
;
_dsolve_quadratic PROC NEAR
PUBLIC _dsolve_quadratic
	PUSH BP							; Preserve BP
	MOV BP,SP						; Set BP to point to parameter area
;
	FLD QWORD PTR [BP+4]			; ST(0) = a
	FMUL Four						; ST(0) = 4*a
	FMUL QWORD PTR [BP+20]			; ST(0) = 4*a*c
	FLD QWORD PTR [BP+12]			; ST(0) = b , ST(1) = 4*a*c
	FMUL ST , ST(0)					; ST(0) = b^2 , ST(1) = 4*a*c
	FSUBRP ST(1) , ST				; ST(0) = b^2 - 4*a*c
	FCOM Zero						; Compare ( b^2 - 4*a*c ) with 0
	FSTSW AX						; Store comparison result in AX
	SAHF							; Store C3, C2, C0 in Flags register
	JAE Positive2					; If ( b^2 - 4*a*c ) >= 0 jump to Positive
		FCHS						; If not, change sign ( ST -> -ST )
		MOV AX , 0					; AX = 0 ( return value )
	Positive2:
	FSQRT							; ST(0) = sqrt( b^2 - 4*a*c )
	FLD QWORD PTR [BP+4]			; ST(0) = a , ST(1) = sqrt( b^2 - 4*a*c )
	FMUL Two						; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )
	FDIV ST(1) , ST					; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	FLD QWORD PTR [BP+12]			; ST(0) = b , ST(1) = 2*a , ST(2) = sqrt( b^2 - 4*a*c )/2a
	FDIVR							; ST(0) = b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	CMP AX , 0						; Compare AX with 0
	JE Complex2						; If AX =0, we have complex roots
		FST Temp					; Temp = b/2a
		FSUBR ST , ST(1)			; ST(0) = sqrt( b^2 - 4*a*c )/2a - b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+32]			; BX = offset r2
		FSTP QWORD PTR [BX]			; *r2 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		FLD Temp					; ST(0) = b/2a , ST(1) = -sqrt( b^2 - 4*a*c )/2a
		FSUB						; ST(0) = -sqrt( b^2 - 4*a*c )/2a - b/2a
		MOV BX , [BP+28]			; BX = offset r1
		FSTP QWORD PTR [BX]			; *r1 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FLD Zero					; ST(0) = 0.0
		MOV BX , [BP+30]			; BX = offset i1
		FST QWORD PTR [BX]			; *i1 = 0.0
		MOV BX , [BP+34]			; BX = offset i2
		FSTP QWORD PTR [BX]			; *i2 = 0.0
		MOV AX , 2					; AX = 2 ( return value )
		JMP SkipComplex2			; Skip calculations for complex roots
	Complex2:
		FCHS						; ST(0) = -b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+28]			; BX = offset r1
		FST QWORD PTR [BX]			; *r1 = -b/2a
		MOV BX , [BP+32]			; BX = offset r2
		FSTP QWORD PTR [BX]			; *r2 = -b/2a
		MOV BX , [BP+34]			; BX = offset i2
		FST QWORD PTR [BX]			; *i2 = sqrt( b^2 - 4*a*c )/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+30]			; BX = offset i1
		FSTP QWORD PTR [BX]			; *i1 = -sqrt( b^2 - 4*a*c )/2a
SkipComplex2:
;
	POP BP							; Restore BP
	RET								; Return from routine
_dsolve_quadratic ENDP
;
; extern int ldsolve_quadratic(long double a, long double b, long double c, long double *r1, long double *i1, long double *r2, long double *i2);
;									[BP+4]			[BP+14]		[BP+24]			[BP+34]			[BP+36]				[BP+38]			[BP+40]
;
_ldsolve_quadratic PROC NEAR
PUBLIC _ldsolve_quadratic
	PUSH BP							; Preserve BP
	MOV BP,SP						; Set BP to point to parameter area
;
	FLD TBYTE PTR [BP+4]			; ST(0) = a
	FMUL Four						; ST(0) = 4*a
	FLD TBYTE PTR [BP+24]			; ST(0) = c , ST(1) = 4*a
	FMUL							; ST(0) = 4*a*c
	FLD TBYTE PTR [BP+14]			; ST(0) = b , ST(1) = 4*a*c
	FMUL ST , ST(0)					; ST(0) = b^2 , ST(1) = 4*a*c
	FSUBRP ST(1) , ST				; ST(0) = b^2 - 4*a*c
	FCOM Zero						; Compare ( b^2 - 4*a*c ) with 0
	FSTSW AX						; Store comparison result in AX
	SAHF							; Store C3, C2, C0 in Flags register
	JAE Positive3					; If ( b^2 - 4*a*c ) >= 0 jump to Positive
		FCHS						; If not, change sign ( ST -> -ST )
		MOV AX , 0					; AX = 0 ( return value )
Positive3:
	FSQRT							; ST(0) = sqrt( b^2 - 4*a*c )
	FLD TBYTE PTR [BP+4]			; ST(0) = a , ST(1) = sqrt( b^2 - 4*a*c )
	FMUL Two						; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )
	FDIV ST(1) , ST					; ST(0) = 2*a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	FLD TBYTE PTR [BP+14]			; ST(0) = b , ST(1) = 2*a , ST(2) = sqrt( b^2 - 4*a*c )/2a
	FDIVR							; ST(0) = b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
	CMP AX , 0						; Compare AX with 0
	JE Complex3						; If AX =0, we have complex roots
		FST Temp					; Temp = b/2a
		FSUBR ST , ST(1)			; ST(0) = sqrt( b^2 - 4*a*c )/2a - b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+38]			; BX = offset r2
		FSTP TBYTE PTR [BX]			; *r2 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		FLD Temp					; ST(0) = b/2a , ST(1) = -sqrt( b^2 - 4*a*c )/2a
		FSUB						; ST(0) = -sqrt( b^2 - 4*a*c )/2a - b/2a
		MOV BX , [BP+34]			; BX = offset r1
		FSTP TBYTE PTR [BX]			; *r1 = sqrt( b^2 - 4*a*c )/2a - b/2a
		FLD Zero					; ST(0) = 0.0
		MOV BX , [BP+36]			; BX = offset i1
		FSTP TBYTE PTR [BX]			; *i1 = 0.0
		FLD Zero					; ST(0) = 0.0
		MOV BX , [BP+40]			; BX = offset i2
		FSTP TBYTE PTR [BX]			; *i2 = 0.0
		MOV AX , 2					; AX = 2 ( return value )
		JMP SkipComplex3			; Skip calculations for complex roots
	Complex3:
		FCHS						; ST(0) = -b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		FST Temp					; Temp = -b/2a
		MOV BX , [BP+34]			; BX = offset r1
		FSTP TBYTE PTR [BX]			; *r1 = -b/2a
		FLD Temp					; ST(0) = -b/2a , ST(1) = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+38]			; BX = offset r2
		FSTP TBYTE PTR [BX]			; *r2 = -b/2a
		FST Temp					; Temp = sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+40]			; BX = offset i2
		FSTP TBYTE PTR [BX]			; *i2 = sqrt( b^2 - 4*a*c )/2a
		FLD Temp					; ST(0) = sqrt( b^2 - 4*a*c )/2a
		FCHS						; ST(0) = -sqrt( b^2 - 4*a*c )/2a
		MOV BX , [BP+36]			; BX = offset i1
		FSTP TBYTE PTR [BX]			; *i1 = -sqrt( b^2 - 4*a*c )/2a
SkipComplex3:
;
	POP BP							; Restore BP
	RET								; Return from routine
_ldsolve_quadratic ENDP
END












