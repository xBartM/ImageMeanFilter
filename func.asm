; Bartlomiej Mielczarek -- 01/06/17
; Project.asm -- Mean filter for 24-bit .bmp files

section	.text
global  func

func:
	push	ebp			; push ebp on stack
	mov	ebp, esp		; set own stack frame pointer

getPassedTabs:	
	mov	esi, DWORD [ebp+8]	; passed &data[0] (ADDRESS) to esi
	mov	edi, DWORD [ebp+12]	; passed &out[0] (ADDRESS) to edi

pushBorderlinesCount:
	mov	ecx, DWORD [ebp+24]	; passed mask size (VALUE) to ecx
	sar	ecx, 1			; get number of "borderlines"
	push	ecx			; push number of borderlines to ebp-4

pushPixelCount:
	mov	eax, DWORD [ebp+16]	; passed width (VALUE) to eax
	mov	ebx, DWORD [ebp+20]	; passed height (VALUE) to ebx
	mov	ecx, DWORD [ebp-4]	; load borderline value to ecx
	;sal	ecx, 1			; 2*borderline in ecx (add this for upper borderline)
	sub	ebx, ecx		; h-b (->(h-2b))
	mul	ebx			; (w)(h-b) (->(w)(h-2b))
	;sub	eax, ecx		; (w)(h-2b)-2b (add this for upper borderline)
	push	eax			; and its on stack [ebp-8]

gotoFirstByte:
	mov	eax, DWORD [ebp+16]	; passed width (VALUE) to eax
	mov	ecx, DWORD [ebp-4]	; load borderline value to ecx
	;inc	eax			; width+1 (add this for bottom borderline)
	mul	cx			; borderline*width (->(borderline*(width+1)))
	mov	dx, 0			; load dx with 0 to multiply again
	mov	cx, 3			; multiply by 3
	mul	cx			; 3*borderline*width (->(3*borderline*(width+1)))

	movzx	eax, ax			; idk if it's doing something
	add	edi, eax		; edi on first pixel to change (B value)

calculateByte:
	mov	eax, 0			; B value
	mov	ebx, 0			; G value
	mov	ecx, 0			; R value
	mov	dh, BYTE [ebp+24]	; dh - vertical mask count
	mov	dl, dh			; dl - horizontal mask count

addRow:
	push	edx			; free one register

	movzx	edx, BYTE [esi]		; move value of B to edx
	add	eax, edx		; add value of B to eax

	inc	esi			; move to G

	movzx	edx, BYTE [esi]		; move value of G do edx
	add	ebx, edx		; add value of G to ebx

	inc	esi			; move to R

	movzx	edx, BYTE [esi]		; move value of R to edx
	add	ecx, edx		; add value of R to ecx

	inc	esi			; move to next pixel

	pop	edx			; get old edx back

	dec	dl			; decrement number of pixels left in mask row
	jnz	addRow			; if there's a pixel to count go back to addRow

gotoNextRow:
	push	edx			; free one register
	mov	edx, DWORD [ebp+16]	; passed width (VALUE) to edx

	add	esi, edx		
	add	esi, edx
	add	esi, edx		; data moved by 3*width

	mov	edx, DWORD [ebp+24]	; passed mask size (VALUE) to edx

	sub	esi, edx
	sub	esi, edx
	sub	esi, edx		; data moved back by 3*mask

	pop 	edx			; get old edx back

	mov	dl, BYTE [ebp+24]	; dl - horizontal mask count
	dec	dh			; decrement number of rows left in mask
	jnz	addRow			; jump back to adding pixels

doActualCalculations:
	push	edx			; free one register
	push	ecx			; free second register
	
	mov	edx, 0			; move 0 to dx - div DX:AX	
	mov	ecx, DWORD [ebp+24]	; passed mask size (VALUE) to ecx

	div	cx			; divide B value by mask
	mov	edx, 0			; cut out rest
	div	cx			; B got divided by mask^2
	mov	BYTE [edi], al		; move average value of B to tab
	inc	edi			; go to next colour (G)
	
	mov	edx, 0			; move 0 to dx - div DX:AX
	mov	eax, ebx		; move G to eax for division

	div	cx			; divide G value by mask
	mov	edx, 0			; cut out rest
	div	cx			; G got divided by mask^2
	mov	BYTE [edi], al		; move average value of G to tab
	inc	edi			; go to next colour (R)

	mov	edx, 0			; move 0 to dx - div DX:AX
	pop	eax			; get ecx back from stack (straight to eax)

	div	cx			; divide R value by mask
	mov	edx, 0			; cut out rest
	div	cx			; G got divided by mask^2
	mov	BYTE [edi], al		; move average value of G to tab
	inc	edi			; go to next pixel

	pop 	edx			; get edx back from stack

gotoNextByte:
	dec	DWORD [ebp-8]		; decrement remaining pixels
	jz	exit			; jump to exit if there's nothing left to do

	mov	esi, DWORD [ebp+8]	; passed &data[0] (ADDRESS) to esi

; data += currout - out - 3*width*borderline - 3*borderline
	mov	eax, DWORD [ebp+12]	; passed &out[0] (ADDRESS) to eax
	mov	ebx, edi		; pinter on out tab
	sub	ebx, eax		; actual offset in out tab
	
	mov	eax, DWORD [ebp-4]	; get borderline from stack
	mov	ecx, 3			; multiply by 3
	mul	cl			; ax = 3*borderline
	sub	ebx, eax		; we only need to substract eax*width

	mov	ecx, DWORD [ebp+16]	; passed width (VALUE) to ecx
	mov	edx, 0			; make sure dx is 0
	mul	cx			; multiply by width
	sub	ebx, eax		; this is the offset

	add	esi, ebx		; now we have the pointer setup

	jmp calculateByte		; and do everything again

exit:
	pop	edx
	pop	edx

	mov	eax, 0
	pop	ebp
	
	ret


