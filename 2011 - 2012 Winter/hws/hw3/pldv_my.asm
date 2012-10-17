.MODEL SMALL
.386
.CODE
; My function: void _polydiv(long int *result, long int *rem, long int *src, int n, long int k);
;                                       bp+4     bp+6           bp+8         bp+10      bp+12
public _polydiv 

_polydiv

proc near

	push bp					; backup bp
    mov bp, sp				; 
	push di					; backup di
	push si					; backup si
            			
    mov bx, [bp+8]  		; &a[i] to bx when a[i] is a coefficient  ///source
    mov di, [bp+4]  		; &result[i] to di when result[i] is output polynomial coefficient  ///destination
            
	mov [di], 0				; use di for result, put into di value 0, because coefficient of x^n in result always is 0, i.e. result[0]=0
	add di, 4				; move forward the di from coefficient of x^n to c'ent of x^(n-1)
			
	mov cx, [bp+10]         ; take to cx value of n
		
loopik:						; loop of : for each i=1 to i<=n result[i]=src[i-1]-k*result[i-1]
	mov eax, [di-4]			; put relust[i-1] into eax  		di		bx			di-4
    imul dword ptr[bp+12]	; k*result[i-1]									
	sub eax, [bx]			; k*result[i-1]-src[i-1]
	neg eax					; -(k*result[i-1]-src[i-1])=src[i-1]-k*result[i-1]
	mov [di], eax			; result[i]=src[i-1]-k*result[i-1]
			
	add di, 4				; result[++i]
	add bx, 4				; src[++i]
			
loop loopik				    ; use loopik
	   
	mov si, [bp+6]			; put *rem into si
	mov eax, [di-4]			; put result[N] into eax
    imul dword ptr[bp+12]	; k*result[N]
	sub eax, [bx]			; k*result[N]-src[N]
	neg eax					; -(k*result[N]-src[N])=src[N]-k*result[N]
	mov [si], eax			; *rem=src[N]-k*result[N]
    
	pop si					; restore si
	pop di					; restore di
    mov sp, bp				; restore bp
    pop bp					; 
            
ret							; return
endp						; end proc
            
end							; end of the program








