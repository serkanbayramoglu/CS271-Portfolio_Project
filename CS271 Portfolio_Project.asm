TITLE Project6  

; Author: Serkan Bayramoglu
; Last Modified: 5 Dec 2021
; email address: bayramoglu.serkan@gmail.com
; Course number/section:   CS271
; Project Number:  Project 6     Due Date: 5 Dec 2021
; Description:	This program uses procedures and macros to;
;				- read ten integers as strings with a loop in main code, using ReadVal procedure, which uses mGetString macro
;				- convert the strings to integer numeric values in ReadVal procedures,
;				- store the numbers in an array of 10 SDWORD numbers,
;				- calculate the sum and average of these numbers,
;				- print the ten numbers, their sum and average as strings, after converting the numeric values to string in WriteVal procedure, which uses mDisplayString macro.
;
;				**EC1:	The program also numbers each line of user input and displays a running subtotal of the user�s valid numbers using WriteVal.
;


INCLUDE Irvine32.inc
; insert macros
mGetString MACRO promptReference, userStringInputReference, promptLength, userInputLengthReference
	push	EDX
	push	ECX
	push	EAX
	push	EDI
	mov		EDX, promptReference
	call	WriteString
	mov		EDX, userStringInputReference
	mov		ECX, promptLength
	call	Readstring
	mov		EDI, userInputLengthReference
	mov		[EDI], EAX
	pop		EDI
	pop		EAX
	pop		ECX
	pop		EDX
ENDM

mDisplayString MACRO displayAddress
	push	EDX
	mov		EDX, displayAddress
	call	WriteString
	pop		EDX
ENDM

; insert constants
PROMPTLENGTH = 13
ARRAYSIZE	= 10


.data
; used by main, pushed to all procedures except introduction and farewell
	stringData		BYTE	PROMPTLENGTH DUP(0)
	userInputNum	SDWORD	?
	userInputLength	DWORD	?

	userInputArray	SDWORD	ARRAYSIZE DUP(0)
	sumIntegers		SDWORD	0
	avgIntegers		SDWORD	0

	commaToPrint	BYTE	", ",0
	counter			BYTE	0
	promptString	BYTE	35 DUP(0)

; to be pushed to introduction
	projTitleMyName	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10
					BYTE	"Written by: Serkan Bayramoglu",13,10,0

	instructions1	BYTE	13,10,"This program prompts for 10 signed decimal integers, displays a list of the integers, ",13,10
					BYTE	"their sum, and their average value. ",13,10,0

	extraCredit1	BYTE	13,10,"**EC1: The program also number each line of user input and displays a running subtotal ",13,10
					BYTE	"	of the user�s valid numbers using WriteVal.",13,10,0

	instructions2	BYTE	13,10,"Please provide 10 signed decimal integers.  ",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ",13,10
					BYTE	"Entered data after the first 10 digits following the sign (if any) will be disregarded!!!",13,10,0

; to be pushed to ReadVal
	promptNumber1	BYTE	"Please enter a signed number ",0								; number to follow as per EC1
	promptNumber2	BYTE	": ",0
	errorMessage	BYTE	"ERROR: You did not enter a signed number or your number was too big. ",13,10
					BYTE	"Please try again",0
	subtotalMessage	BYTE	"The subtotal of the integer(s) entered up to now is: ",0		; subtotal to follow as per EC1


; to be pushed to WriteVal
	displayMessage1	BYTE	13,10,"You entered the following numbers: ",13,10,0
	displayMessage2	BYTE	"The sum of these numbers is: ",0
	displayMessage3	BYTE	"The truncated average is: ",0


; used by farewell
	goodbye1		BYTE	13,10,"Goodbye, and thanks for playing! ",13,10,0


.code
main PROC

; introduction
	push	OFFSET projTitleMyName
	push	OFFSET instructions1
	push	OFFSET instructions2
	push	OFFSET extraCredit1
	call	introduction

; initiate data before starting the loop to query and store the integers
	mov		ECX, ARRAYSIZE
	mov		EDI, OFFSET userInputArray
	mov		EAX, 0
	mov		sumIntegers, EAX
	mov		avgIntegers, EAX

	mov		EBX, 0				; EBX will be the counter showing the number of the integer to be entered


_promptForNumbers:
; print the number of the integer to be entered as per EC1
	inc		EBX

	mov		EDX, OFFSET promptNumber1
	call	WriteString
	push	EBX
	push	OFFSET stringData
	call	WriteVal					; convert and display the sum

; Get valid integers from the user, store them in the array, find their sum
	push	OFFSET errorMessage
	push	OFFSET userInputNum
	push	OFFSET promptNumber2
	push	OFFSET stringData
	push	PROMPTLENGTH
	push	OFFSET userInputLength
	call	ReadVal					; get the numeric values

	mov		EAX, userInputNum
	mov		[EDI], EAX				; store the numeric values in the array

	mov		EAX, sumIntegers		; add the integers
	add		EAX, userInputNum
	mov		sumIntegers, EAX

	; display the subtotal
	mov		EDX, OFFSET subtotalMessage
	call	WriteString
	push	sumIntegers
	push	OFFSET stringData
	call	WriteVal					; convert and display the sum	call	Crlf
	call	Crlf

	add		EDI, 4
	loop	_promptForNumbers

; find the truncated average of the integers
	mov		EAX, sumIntegers
	CDQ
	mov		EBX, ARRAYSIZE
	idiv	EBX
	mov		avgIntegers, EAX

; Display the integers, their sum, and their truncated average.
	mov		EDX, OFFSET displayMessage1
	call	WriteString

; Initiate the array for the loop
	mov		ESI, OFFSET userInputArray
	mov		ECX, LENGTHOF userInputArray

_displayNumbers:
; Get stored integers in the array, store them in userInputNum, call WriteVal to conver the numeric value to string and print the string
	mov		EAX, [ESI]			; store the numeric values in the array into userInputNum
	mov		userInputNum, EAX

	push	userInputNum
	push	OFFSET stringData
	call	WriteVal					; convert and display the numeric values

	cmp		ECX, 1
	je		_finalLoop
	mov		EDX, OFFSET commaToPrint
	call	WriteString
_finalLoop:
	add		ESI, 4
	loop	_displayNumbers
	call	Crlf

	mov		EDX, OFFSET displayMessage2
	call	WriteString
	push	sumIntegers
	push	OFFSET stringData
	call	WriteVal					; convert and display the sum
	call	Crlf

	mov		EDX, OFFSET displayMessage3
	call	WriteString
	push	avgIntegers
	push	OFFSET stringData
	call	WriteVal					; convert and display the truncated average
	call	Crlf

; say goodbye
_sayGoodbye:
	push	OFFSET goodbye1
	call	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; This procedure contains the introduction of the program and name of the author
;
; Preconditions: None
;
; Postconditions: None None
;
; Receives: [EBP + 12]:	extraCredit1
;			[EBP + 16]:	instructions2
;			[EBP + 20]:	instructions1
;			[EBP + 24]:	projTitleMyName
;
; Returns: Messages are displayed
; ----------------------------------------------------------------------------------
introduction PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP

	mov		EDX, [EBP + 24]				; Base + Offset used for accessing runtime stack parameters
	call	WriteString
	mov		EDX, [EBP + 20]
	call	WriteString
	mov		EDX, [EBP + 12]
	call	WriteString
	mov		EDX, [EBP + 16]
	call	WriteString
	call	CrLf

	pop		EBP
	ret		16
introduction ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure is to prompt for a 32 bit SDWORD number and return the number in
; string format.
;
; Preconditions: None
;
; Postconditions: None (
;
; Receives: [EBP + 20]: address of promptNumber2
;			[EBP + 12]: PROMPT_LENGTH value
;			[EBP + 28]: address of errorMessage
;			[EBP + 16]: address for stringData
;			[EBP +  8]: address for userInputLength
;
; Returns:	[EBP + 24]: address for SDWORD type number converted from user input
;
; ----------------------------------------------------------------------------------
ReadVal PROC
	LOCAL	multiplier:SDWORD, tempAL:BYTE, stringLength:DWORD

; saved registers
	PUSHAD

; Invoke the mGetString macro to get user input in the form of a string of digits
_callMacro:
	mGetString [EBP + 20], [EBP + 16], [EBP + 12], [EBP + 8]    ; Base + Offset used for accessing runtime stack parameters

; initiate the validation and convertion of the string to a SDWORD number
	mov		ESI, [EBP + 8]
	mov		ECX, [ESI]
	mov		stringLength, ECX	; set the counter

	cmp		stringLength, 0		; if the string length is 0  => nothing is entered  => entry is not valid
	jz		_notValid

	mov		ESI, [EBP + 16]		; ESI set to the user input string
	mov		EDI, [EBP + 24]		; EDI set to the numeric value to be returned

	CLD							; clear direction flag
	mov		multiplier, 1		; set number to positive by setting multiplier to +1

_conversionLoop:
	mov		EAX, 0				; cleaning the EAX register, when AL is set to a 1 Byte number, EAX will show the same number in 4 Bytes
	LODSB

	; check if the first character of the entered string is a sign (+ or -)
	cmp		AL, '-'
	jne		_checkPositive
	cmp		ECX, stringLength		; if the '-' is the first character, make the multiplier -1
	jne		_notValid				; otherwise the entry is not a valid number (such as 12-345)
	cmp		stringLength, 1			; if the netry is only '-' => the string length is 1 => the entry is not a valid number
	je		_notValid
	mov		multiplier, -1
	LODSB							; if the first string is '-', initiate number with the next string, and jump to _convertFirst to convert to number
	dec		ECX
	jmp		_convertFirst
_checkPositive:
	cmp		AL, '+'
	jne		_noSign
	cmp		ECX, stringLength		; if the '+' is the first character, no action needed (the multiplier is already +1 no need to change it)
	jne		_notValid				; otherwise the entry is not a valid number (such as 12+345)
	cmp		stringLength, 1			; if the netry is only '+' => the string length is 1 => the entry is not a valid number
	je		_notValid
	LODSB							; if the first string is '+', initiate number with the next string, and jump to _convertFirst to convert to number
	dec		ECX
	jmp		_convertFirst
_noSign:							; if the first character of the string is numberic (0 to 9), initiate the number from this point
	cmp		AL, 48
	jb		_notValid
	cmp		AL, 57
	ja		_notValid

	cmp		ECX, stringLength
	jne		_jumpMultiply
_convertFirst:
	cmp		AL, 48
	jb		_notValid
	cmp		AL, 57
	ja		_notValid

	sub		AL, 48		; Converting the string of ascii digits to its numeric value representation (each digit in BYTE, total number in SDWORD)
	imul	multiplier
	mov		[EDI], EAX
	jmp		_continueLoop
_jumpMultiply:
	sub		AL, 48
	mov		tempAL, AL	; storing AL data to temporary local variable, as EAX needs to be used for other calculations, which will affect AL
	mov		EBX, 10
	mov		EAX, [EDI]
	imul	EBX
	jo		_notValid	; after multiplication if overflow flag is set => the number entered is too large (above SDWORD size) => not valid
	movzx	EBX, tempAL
	imul	EBX, multiplier
	add		EAX, EBX
	jo		_notValid	; after adition if overflow flag is set => the number entered is too large (above SDWORD size) => not valid
	mov		[EDI], EAX

_continueLoop:
	loop	_conversionLoop

	jmp		_return

_notValid:				; if nothing is entered, or entered text is not numeric or the number is too big, therefore the entered string is not valid
	mov		EDX, [EBP + 28]
	call	WriteString
	jmp		_callMacro

_return:
	POPAD
	ret		24
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure is to display the numbers as string , after converting to string
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [EBP + 12]: value of SDWORD type number to be printed as string
;			[EBP +  8]: stringData
;
;
; Returns:	None - displays the numeraic value as a string
; ----------------------------------------------------------------------------------
WriteVal PROC
	LOCAL	valCheck:DWORD
	PUSHAD

; Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
	mov		EDI, [EBP +  8]
	CLD
	mov		EAX, [EBP + 12]
	cmp		EAX, 0
	jg		_continueConversion
	je		_continueZero
	mov		EAX, [EBP + 12]
	imul	EAX, -1
	mov		[EBP + 12], EAX

	mov		AL, '-'
	STOSB

_continueConversion:
	mov		valCheck, 0		; at this stage no number is written to register
	mov		EAX, [EBP + 12]
	mov		ECX, 10
	mov		EBX, 1000000000
_conversionLoop:
	mov		EDX, 0
	div		EBX
	cmp		valCheck, 1
	je		_noCheck	; if EBX = 1, write to register even if AL = 0
	cmp		AL, 0
	je		_noAction
_noCheck:
	mov		valCheck, 1
	add		EAX, 48
	STOSB
_noAction:
	push	EDX
	mov		EAX, EBX
	mov		EBX, 10
	mov		EDX, 0
	div		EBX
	mov		EBX, EAX
	pop		EAX				; pop the previous EDX into EAX
	loop	_conversionLoop
	jmp		_completeAndDisplay

_continueZero:
	mov		AL, 48
	STOSB

_completeAndDisplay:
	mov		AL, 0
	STOSB

; Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.
	mDisplayString [EBP + 8]

	POPAD
	ret		8
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: farewell
;
; This procedure displays goodbye message at the end of the program
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [EBP + 12]; goodbye1
;
; Returns: Goodbye message is displayed
; ----------------------------------------------------------------------------------
farewell PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP

	call	CrLf
	mov		EDX, [EBP + 12]
	call	WriteString
	call	CrLf

	pop		EBP
	ret		4
farewell ENDP


END main
