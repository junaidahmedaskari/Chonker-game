; ***********************************

; First, some assembler directives that tell the assembler:
; - assume a small code space
; - use a 100h size stack (a type of temporary storage)
; - output opcodes for the 386 processor
.MODEL small
.STACK 100h
.386

; Next, begin a data section
.data
	msg DB "CHONKER DEAD! TRY AGAIN",0,'$'	; first msg reference: http://www.sce.carleton.ca/courses/sysc-3006/f11/Part20-SoftwareInterrupts.pdf
	nSize DW ($ - msg)-1

	randNum DB   45, 19, 32, 70, 56, 61, 24, 52, 36, 7, 2, 69, 15, 57, 67, 79, 71, 18, 47, 60
			DB   52, 47, 29, 30, 19, 40, 20, 73, 32, 28, 49, 74, 62, 41, 55, 34, 26, 61, 25, 2
			DB   79, 75, 54, 25, 64, 9, 66, 49, 27, 10, 35, 62, 74, 5, 50, 55, 13, 16, 34, 12
			DB   63, 40, 50, 59, 60, 30, 61, 65, 39, 9, 11, 27, 57, 37, 62, 31, 17, 19, 28, 29
			DB   24, 4, 59, 57, 69, 47, 30, 12, 26, 9, 6, 70, 73, 8, 15, 64, 41, 36, 42, 2
			DB   18, 44, 64, 75, 1, 51, 39, 57, 52, 76, 66, 21, 7, 50, 27, 9, 67, 24, 19, 30
			DB   48, 72, 1, 22, 51, 14, 47, 54, 63, 38, 62, 5, 71, 18, 43, 17, 76, 42, 70, 28
			DB   30, 3, 74, 17, 8, 11, 57, 72, 9, 76, 70, 18, 71, 77, 62, 53, 32, 79, 67, 14
			DB   51, 31, 47, 40, 63, 24, 3, 50, 78, 49, 27, 15, 71, 41, 58, 54, 37, 66, 34, 45
			DB   32, 26, 68, 79, 38, 73, 10, 3, 41, 64, 6, 36, 44, 53, 11, 31, 35, 16, 70, 7
			DB   18, 35, 44, 20, 6, 15, 26, 48, 64, 3, 61, 70, 9, 1, 72, 75, 52, 10, 2, 11
			DB   21, 38, 19, 53, 20, 13, 15, 35, 42, 66, 60, 71, 63, 58, 11, 78, 31, 62, 61, 12
			DB   72, 48, 58, 42, 22, 75, 70, 24, 38, 14, 8, 32, 41, 20, 57, 36, 67, 44, 37, 60
			DB   17, 32, 46, 21, 65, 28, 55, 34, 56, 44, 49, 7, 33, 42, 26, 18, 67, 62, 2, 19
			DB   75, 72, 79, 30, 33, 26, 67, 44, 31, 36, 22, 2, 35, 25, 61, 4, 55, 37, 64, 50
			DB   75, 69, 66, 27, 72, 31, 22, 40, 73, 38, 16, 23, 34, 42, 30, 4, 11, 24, 50, 43
			DB   18, 15, 14, 71, 72, 27, 5, 34, 35, 16, 58, 21, 9, 75, 68, 29, 40, 79, 73, 42
			DB   42, 45, 71, 43, 3, 9, 74, 76, 44, 1, 75, 59, 31, 30, 21, 70, 8, 79, 23, 33
			DB   45, 35, 26, 20, 74, 77, 8, 31, 51, 58, 13, 72, 15, 9, 33, 12, 29, 78, 76, 19
			DB   15, 22, 69, 21, 46, 36, 39, 19, 78, 70, 64, 1, 50, 12, 26, 51, 40, 43, 68, 75
		
	randSize DW ($-randNum)-1
	
	randPtr DW 0

	xCUR DB 20h
	yCUR DB 8h

	
; all the software interrupts in this code were derived from: http://www2.ift.ulaval.ca/~marchand/ift17583/dosints.pdf
	

.code

; This procedure creates a 0.1 second delay.

delay proc
	MOV CX, 01h
	MOV DX, 86A0h
	MOV AH, 86h
	INT 15h	; 1 seconds delay	
	RET
delay ENDP

;some commonly used procedures
	setCURpos proc  ; procedure to set the cursor using the int 10h interrupt 
		MOV AH, 02h ;
		MOV BH, 0h  ; sets the display page to the first page
		INT 10h  ;	
		RET
	setCURpos endp

	readCur proc 	; procedure to read the value at the cursor using int 10h interrupt
		MOV AH, 08h ;
		MOV BH, 00h ; sets the display page to the first page
		INT 10h	    ;
		CMP AL, "0" ; compares the value at the cursor to see if it matches "0"
		RET
	readCur endp

	writeCur proc	; proc to write at the cursor using the int 10h interrupt
		PUSH CX     ;
		MOV AH, 09h ;
		MOV BH, 00h ;
		MOV CX, 01h ;
		INT 10h
		POP CX      ; Saving the value inside CX on the stack 
		RET
	writeCur endp		
;
;
;
;
;


; This is the main procedure. 
_main PROC
	
	

; This is the start of the loop that will run continuously
	XOR SI, SI ; reset SI 
	XOR DI, DI ; reset DI 
	MOV SI, OFFSET randNum; points SI to the addr of the first value in randNum
OuterLoop:	

; set the segment registers.
	
	MOV DX, @data
	MOV DS, DX

; draw some rocks 
;
;code here for drawing rocks.
	MOV CX, 5; ; sets the value of the rocks to be drawn per line, 5, into the CX register	
	MOV DX, DS ; saves the DS pointer into DX register to later save into the ES pointer
	MOV ES, DX
loop2:
	MOV DL, byte ptr [SI]
	MOV DH, 18h 	      ; 
	CALL setCurpos	      ; sets cursor position at the bottom of the screen 
	MOV AL, "X"	          ;
	MOV BL, 05h           ; color code taken from http://www.brackeen.com/vga/basics.html
	CALL writeCur 	      ;	starts writing (drawing) rocks at the bottom of the screen
	INC SI
	LOOP loop2
	

	
;

; scroll the screen
	
	MOV AH, 06h   ; 
	MOV AL, 1     ; 
	MOV CX, 00h   ; 
	MOV DX, 1850h ;	
	INT 10h       ; 

; see if a rock hit the chonker
	MOV DH, [yCUR] ; sets the row to the y position of the chonker
	MOV DL, [xCUR] ; sets the coloumn to the x position of the chonker
	CALL setCurpos
	CALL readCUR   ; checks to see if the chonker (cursor) hit the rock ("0")
	JE terminate   ; terminates if the above conditon is met


; if chonker is safe, draw the chonker
; Your code to draw the chonker. Maybe another INT call?
	MOV AL,"@" 
	MOV BL, 11h ;sets the chonker head color to light cyan (from http://www.brackeen.com/vga/basics.html) 
	MOV CX, 01h	
	CALL writeCur 	;draws the chonker head

; We wait 0.1 second.	
	CALL delay     

; If the "q" is pressed, end the program otherwise loop through the code again.
	

;CHECK IF KEY WAS PRESSED.
	mov AH, 0bh
  	int 21h      ;RETURNS AL=0 if NO KEY PRESSED otherwise AL!=0 if KEY PRESSED.
  	cmp AL, 0
  	je  noKey

;PROCESS KEY.        
;
; check if left or right key was pressed.
; Maybe an INT call for this?
; Use some program flow control logic to get
; to either the moveleft or the moveright section
; of code as needed.

	MOV AH, 01h 
	INT 16h		  ; int 16h interrupt used to check the keyboard input 
	CMP AL, "q"   ; input compared to "q"
	JE  terminate ; if q is pressed by the user, game terminates

	MOV AH, 01h 
	INT 16h
	CMP AL, "a" 
	JE  moveleft ; if a is pressed by the user, jump to the moveleft function below
	
	MOV AH, 01h 
	INT 16h
	CMP AL, "d" 
	JE  moveright ;if d is pressed by the user, jump to the moveright function below
	
	


noKey:
;
; Some code related to drawing the tunnel could go here.
	MOV AL,"x" ;sets the character used for drawing the chonker tunnel
	MOV BL, 12h ;sets the color of the tunnel to red (http://www.brackeen.com/vga/basics.html)
	CALL writeCur ; 
	MOV AH, 0Ch 
	INT 21h 		; int 21h interrupt used to erase the keyboard input
	CMP AL, 0Ah
	JMP OuterLoop ; jumops to outerloop loop if no key is pressed

moveleft:
; some code about moving left could go here.
	DEC xCUR ; decrements the chonker (cursor) tunnel position to move it one unit to the left
	MOV AL,"x" ; redraws the chonker tunnel at the new decremented position with the character x
	MOV BL, 12h ; 
	CALL writeCur ;  
	MOV AH, 0Ch
	INT 21h 
	CMP AL, 0Ah
	JMP OuterLoop

moveright:
; some code about moving right could go here.
	INC xCUR ; increments the chonker (cursor) tunnel position to move it one unit to the left
	MOV AL,"x" ; redraws the chonker tunnel at the new incremented position with the character x
	MOV BL, 12h ;
	CALL writeCur ; 
	MOV AH, 0Ch
	INT 21h 
	CMP AL, 0Ah
	JMP OuterLoop

terminate:
; An INT call exists to print a string (about the Chonker being terminated).
; reference for the code below: http://www.sce.carleton.ca/courses/sysc-3006/f11/Part20-SoftwareInterrupts.pdf
	MOV DX, 00h
	;MOV DH, [yCUR] ; sets the row to the y position of the chonker
	;MOV DL, [xCUR] ; sets the coloumn to the x position of the chonker
	CALL setCurpos
	MOV AH, 09h
	MOV DX, OFFSET msg
	INT 21h
; exit the program.
	MOV AX, 4C00h
	INT 21h
_main ENDP
END _main
