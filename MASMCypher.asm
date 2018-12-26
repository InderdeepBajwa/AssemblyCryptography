; Question2.asm	-	Checks the password using the hash function
; Author		-	Inderdeep Singh Bajwa

INCLUDE irvine32.inc		;		Including Irvine Library

.386
.model flat,stdcall
.stack 4096
							;		Prototypes here

ExitProcess proto,dwExitCode:dword
HashFunc PROTO
printDots PROTO
resetIs PROTO
safePrompt1 PROTO
safePrompt2 PROTO
CheckLength PROTO
CheckPassword PROTO

.data
						;		Prompts
entrPswrd		BYTE	"Enter your password: ", 0
entrPswrdAgain	BYTE	"Try your password again: ", 0
HASHED			BYTE	"Checking Your Password ", 0
lessFive		BYTE	"You entered password less than 5.", 0
ExitInformation	BYTE	"You've attempted 3 times", 0
PassIsWrong		BYTE	"Your password is wrong. Police is being called ", 0

						;		Error Handling Prompt
lengthError		BYTE	"Your string size is less than 5 characters", 0
UnsuccessPrint	BYTE	"Password Unaccepted!", 0

SuccessPrint	BYTE	"Password accepted!", 0

						;		Variables
hashString		BYTE	256 DUP(?), 0
attemptCheck	BYTE	0;
finalcheck		BYTE	0;
stringLength	DWORD	0;
GarbageCollection	BYTE	"Garbage", 0
Attempts		BYTE	0;
SumSum			DWORD	0;

						;		Utilities
dot		BYTE	".",0

.code
main proc

	call	resetIs		;		Resets all required registers to zero

	ProgBegin:			;		Program begins here
		mov		ecx,	256
		call	safePrompt1	;	Prompts the user

		mov		edx,	OFFSET hashString
		call	ReadString
		mov		stringLength,	eax
		call	CheckLength
	AfterCheck::		;		
		mov		ecx,	256
		call	safePrompt2
		mov		edx,	OFFSET hashString
		call	ReadString
		mov		stringLength,	eax
		call	CheckLength

	

	BreakOutLoop::
		mov		edx,	OFFSET UnsuccessPrint
		call	WriteString
		call	CRLF
		jmp		ExitProgram

	WrongPassword::
		mov		edx,	OFFSET PassIsWrong
		call	WriteString
		call	printDots
		call	CRLF
		jmp		ExitProgram

	Done::
		mov		edx,	OFFSET SuccessPrint
		call	WriteString
		call	CRLF
		jmp		ExitProgram


	ExitProgram:
		nop

	invoke ExitProcess,0
main endp

HashFunc PROC
	mov		edx,	OFFSET HASHED
	call	WriteString
	call	printDots
	call	crlf

	; Adding ASCII codes of all characters
	call	resetIs

	movzx		eax,	[hashString]
	mov		ecx,	1
	AddAscii:
		movzx	ebx,		[hashString + ecx]
		add		eax,	ebx
		inc	ecx
		cmp	ecx,	stringLength
		jb	AddAscii
		;	Eax has sum of characters

	; Add Modulo
	mov		SumSum,		eax

	mov		edx,	0
	mov		ebx,	313
	div		ebx					;	Edx has the remainder
	ror		edx,	2
	xor		edx,	217
	mov		eax,	edx
	
	
	call	CheckPassword

	; Hash 
	jmp	Done
	ret
HashFunc ENDP

printDots PROC
	mov		ecx,	4
	mov		edx,	OFFSET dot
	mov		eax,	200
	printDot:
		call	delay
		call	WriteString
	loop printDot
	call resetIs
	ret
printDots ENDP

resetIs PROC
	mov		eax,	0
	mov		ebx,	0
	mov		ecx,	0
	mov		edx,	0
	ret
resetIs	ENDP

safePrompt1 PROC
	mov		edx,	OFFSET entrPswrd
	call	WriteString
	mov		edx,	0
	ret
safePrompt1 ENDP

safePrompt2 PROC
	mov		edx,	OFFSET entrPswrdAgain
	call	WriteString
	mov		edx,	0
	ret
safePrompt2 ENDP

CheckLength PROC
	.IF (stringLength < 5)
		mov		edx,	OFFSET lessFive
		call	WriteString
		Call	CRLF
		inc		Attempts
		.IF (Attempts >= 3)
			jmp WrongPassword
		.ENDIF
		jmp		AfterCheck
	.ELSE
		call	HashFunc
	.ENDIF
	ret
CheckLength ENDP

CheckPassword PROC
	cmp		edx,	3221225681
	je		Done
	inc		Attempts
	.IF (Attempts < 3)
		jmp AfterCheck
	.ENDIF
	jmp		WrongPassword
CheckPassword ENDP

end main
