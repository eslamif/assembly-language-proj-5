TITLE Sorting Random Integers     (ass_5.asm)

; Author: Frank Eslami
; Course / Project ID: CS271-400 / Project #5              Date: 11/22/2014
; Description: This program generates random numbers in the range [100 .. 999], displays the original list, sorts 
; the list, and calculates the median value. Finally, it displays the list sorted in descending order.

INCLUDE Irvine32.inc

;min and max range of the number of random integers to generate
MIN = 10
MAX = 200

;low and high range of random integers to generate
LO = 100
HI = 999

.data
intro1			BYTE	"Welcome to Sorting Random Integers! My name is Frank Eslami.", 0
intro2			BYTE	"This program generates random numbers in the range [100 .. 999], displays the original list,"
				BYTE	" sorts the list, and calculates the median value. Finally, it displays the list sorted in descending order.", 0
promptUser		BYTE	"How many numbers should be generated? ", 0
invalidInt		BYTE	"Invalid input", 0
arrTitle1		BYTE	"The unsorted random numbers:", 0
arrTitle2		BYTE	"The sorted list:", 0
arrForm1		BYTE	"     ", 0	;5 spacing between elements
arrForm2		DWORD	1			;elements per line counter
unsortedMess	BYTE	"The unsorted random numbers:", 0	
medianMess		BYTE	"The median is: ", 0

userGenInput	DWORD	?	;stores random numbers to be generated
randArr			DWORD	MAX DUP(?)	;reserve space for random numbers generated up to the max allowed
randArrSize		DWORD	?		    ;size of array (filled elements)
range			DWORD	?		    ;range of random numbers to generate

.code
;********************* START Procedure Definitions *********************

;Title: intro 
;Description: introduce the program and programmer
;Receives: none
;Returns: none
;Precondition:none
;Registers changed: none

intro PROC
	mov		edx, OFFSET intro1						;introduce programmer and program title.
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET intro2						;introduce program
	call	WriteString
	call	CrLf
	call	CrLf
	ret
intro ENDP
;---------------------------------------------------------------------------------------------------------

;numsToGen 
;Description: obtain & validate user's input for the number of random numbers to generate
;Receives: @userGenInput, @promptUser, @invalidInt
;Returns: [userGenInput] = int in range of [10, 200]
;Precondition: global userGenInput declared, promptUser & invalidInt initialized
;Registers changed: none

numsToGen PROC
	push	ebp										;save old ebp
	mov		ebp, esp					
ObtainInput:
	;Prompt user for the number of random numbers to be generated
	mov		edx, [ebp+16]							;prompt user for input
	call	WriteString
	call	ReadInt									;obtain integer from user
	mov		[ebp+8], eax							;store input in global userGenInput
	call	CrLf

	;Validate user's input to be in the range [10, 200]
	cmp		eax, min								;compare user's input to min range allowed
	jl		InvalidInput							;if user's input < min input is invalid
	cmp		eax, max								;compare user's input to max range allowed
	jg		InvalidInput							;if user's input > max input is invalid
	jmp		Valid									;input is valid

InvalidInput:
	mov		edx, [ebp+12]							;warn user of invalid input
	call	WriteString
	call	CrLF
	jmp		ObtainInput								;obtain new input

Valid:
	mov		userGenInput, eax						;store user's input
	pop		ebp										;restore old ebp
	ret		12										;pop EBP+8
numsToGen ENDP
;---------------------------------------------------------------------------------------------------------

;GenRandNums
;Description: generate random integers and store them in an array
;Receives: global userGenInput
;Returns: randArray of size userGenInput of random integers in range [100, 999]
;Precondition: int userGenInput in range of [10, 200]
;Precondition2: randArray declared to MAX capacity
;Registers changed: none

GenRandNums PROC
	push	ebp										;save old ebp
	mov		ebp, esp

	;Calculate range [LO, HI]
	mov		eax, HI									;high range
	sub		eax, LO									;HI - LO
	inc		eax										;eax + 1
	mov		ebx, [ebp+20]							;address of range
	mov		[ebx], eax								;store range

	;Generate random numbers and store them in array
	mov		ecx, [ebp+16]							;set loop counter to user's input
	mov		esi, [ebp+12]							;1st element of global array
Generate:
	mov		ebx, [ebp+20]							;global range variable address
	mov		eax, [ebx]								;global range variable value
	call	RandomRange								;generate random number based on global range
	add		eax, LO									;adjust random generator for min value

	;Store random number in array
	mov		[esi], eax								;store random integer in current array index
	add		esi, 4									;add 4 bytes to current array index for next index

	;Increment array size by 1
	mov		ebx, [ebp+8]							;size of array
	mov		eax, 1									
	add		[ebx], eax								;increment array size by 1

	loop	Generate								;obtain & store more random numbers

	pop		ebp										;restore old ebp
	ret		16
GenRandNums ENDP
;---------------------------------------------------------------------------------------------------------

;DisplayArr
;Description: display array elements
;Receives: @arrTitle, @randArr, randArrSize 
;Returns: displays array's title with its elements, 10 per line
;Precondition: @arrTitle, @randArr, randArrSize have been inititalized
;Registers changed: none

DisplayArr PROC
	push	ebp										;save old ebp
	mov		ebp, esp

	;Display array's title
	mov		edx, [ebp+16]							;array's title
	call	WriteString					
	call	CrLf	

	;Display array
	mov		ecx, [ebp+8]							;number of elements in array
	mov		esi, [ebp+12]							;array
More:
	mov		eax, [esi]								;current array element
	call	WriteDec

	;Format array output
	mov		edx, OFFSET arrForm1					;5 spaces between elements
	call	WriteString
	mov		eax, arrForm2							;number of elements per line counter
	mov		ebx, 10
	mov		edx, 0
	div		ebx
	cmp		edx, 0
	jne		SameLine
	call	CrLf
SameLine:
	add		esi, 4									;add 4 bytes to current array element for next element
	inc		arrForm2								;increment line counter by 1
	loop	More									;display more elements

	call	CrLF
	pop		ebp										;restore old ebp
	ret		12
DisplayArr ENDP
;---------------------------------------------------------------------------------------------------------

;Sort
;Description: sort array
;Receives: @arrTitle, @randArr, randArrSize
;Returns: displays sorted array
;Precondition: the parameters received must be initialized
;Registers changed: none

Sort PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]							;size of array (filled elements)
L1:
	mov		esi, [ebp+12]							;array's current element
	mov		edx, ecx
L2:
	mov		eax, [esi]
	mov		ebx, [esi+4]
	cmp		ebx, eax
	jle		L3										;if current element <= next element
	mov		[esi], ebx								;swap elements since current element > next element
	mov		[esi+4], eax

L3:
	add		esi, 4
	loop	L2
	mov		ecx, edx
	loop	L1

	pop		ebp
	ret		8
Sort ENDP

;---------------------------------------------------------------------------------------------------------

;Median
;Description: calculate the median
;Receives: @medianMess, @randArr, randArrsize
;Returns: median
;Precondition: @randArr must be sorted. Remaining parameters must be initialized
;Registers changed: none

Median PROC
	push	ebp										;save old ebp
	mov		ebp, esp

	;Determine whether the number of elements are even or odd
	mov		eax, [ebp + 8]							;array size
	mov		edx, 0									;set to 0 for remainder
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		IsEven									;array size is even

	;Array size is odd
	inc		eax										;add 1 to quatient to get median
	jmp		Display

IsEven:
	mov		ebx, eax								
	inc		ebx										;ebx = eax + 1
	add		eax, ebx								
	mov		ebx, 2
	div		ebx										;note that the instructions said this "may be rounded." I assumed it was optional.
	jmp		Display

Display:
	mov		edx, OFFSET medianMess					;median message
	call	WriteString
	call	WriteDec
	call	CrLf

	pop		ebp										;restore old ebp
	ret		12
Median ENDP
;---------------------------------------------------------------------------------------------------------

;********************* END Procedure Definitions *********************


main PROC
	call		Randomize				;create seed for RandomRange procedure
	call		intro					;introduce program and obtain user's input

	;Obtain & validate user's input for the number of random numbers to generate
	push		OFFSET promptUser		;pass string argument to prompt user for input
	push		OFFSET invalidInt		;pass string argument to warn for invalid input
	push		OFFSET userGenInput		;pass argument to store user's input
	call		numsToGen				;procedure to validate & store user's input

	;Generate random numbers and store them in an array
	push		OFFSET range			;pass argument for range of random numbers to generate
	push		userGenInput			;pass argument for random numbers to generate
	push		OFFSET randArr			;pass argument for array to store random numbers
	push		OFFSET randArrSize		;pass argument for array's size (number of filled elements)
	call		GenRandNums				;procedure to generate & store random numbers in an array

	;Display unsorted random numbers to user
	push		OFFSET arrTitle1		;title of array
	push		OFFSET randArr			;1st element of array
	push		randArrSize				;array size (filled elements)
	call		DisplayArr				;call procedure to display array elements


	;Sort unsorted array
	push		OFFSET randArr			;1st element of array
	push		randArrSize				;array size (filled elements)
	call		Sort					;call procedure to sort array		


	;Display sorted random numbers to user
	push		OFFSET arrTitle2		;title of array
	push		OFFSET randArr			;1st element of array
	push		randArrSize				;array size (filled elements)
	call		DisplayArr				;call procedure to display array elements

	;Display Median
	push		OFFSET medianMess		;median message
	push		OFFSET randArr			;1st element of array
	push		randArrSize				;array size (filled elements)
	call		Median					;call procedure to display median


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
