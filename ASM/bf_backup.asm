.MODEL MEDIUM
.STACK 64
.DATA
	SCREEN_WIDTH DW 320
	SCREEN_HEIGHT DW 190

	FPS_CONTROLLER DB 0 ; USED IN MAIN TO CONTROLL FPS, MAIN IS EXCUTED IN EVERY 1 MILISECONDS SO THE FRAME RATE IS 100 FPS
	
	BALL_POS_X DW 30 ; COORDINATES OF THE TOP 
	BALL_POS_Y DW 100 ; LEFT CORNER OF THE BALL
	BALL_SIZE DW 4 ; HEIGHT AND WIDTH OF THE BALL

	BALL_SPEED DW 0 ; CURRENT SPEED OF BALL
	BALL_JUMP_ACC DW 10 ; ACCELARATION OF BIRD LIFTING FORCE
	BALL_JUMP_FORCE_DURATION DW 2 ; SET TO (N-1) IF WANT N MILLISECONDS
	FORCE_DURATION_COUNTER DB 0
	BALL_JUMP_COUNTER DW 0
	BALL_JUMP_CONDITION DW 0

	GRAVITY_ACC DW 100
	GRAVITY_COUNTER DW 0
	GRAVITY_COUNTER_CONDITION DW 10
	BARRIERS_SPEED DW 2 ; SPPED OF BARRIERS OR ACTUALLY HORIZANTAL SPEED OF THE BIRD DUE TO RELATIVITY THEORY
	
	RANDOM_BARRIER_HEIGHT_NUMBER DW 0
	RANDOM_RANGE DW 0 ; USED BY GEN_RANDOM_WITH_RANGE
	RANDOM_NUMBER DW 0 ; GENERATED BY GEN_RANDOM
	LCG_SEED DW 0 ; SEED FOR LCG ALGORITHM
	
	BARRIER_HEIGHT DW 40  ; HEIGHT OF THE BARRIERS
	BARRIER_WIDTH DW 2 ; WIDTH OF THE BARRIERS
	
	BARRIER_POS_X DW 0
	BARRIER_POS_Y DW 0
	
	BARRIER_QUEUE_X DW 32 DUP(?) ; COLLECTION OF BARRIERS THAT APPEAR ON THE SCREEN
	BARRIER_QUEUE_Y DW 32 DUP(?)
	BARRIER_QUEUE_HEIGHT DW 32 DUP(?)
	
	BARRIER_QUEUE_FRONT DB 0 ; CIRCULAR QUEUE
	BARRIER_QUEUE_REAR DB 0

	BARRIER_ADD_NEW_COUNTER DW 0
	BARRIER_ADD_NEW_CONDITION DW 0

	INIT_BARRIER_QUEUE_COUNTER DW 0
	
	GAME_OVER DB 0
	
	SCORE DW 0
	SCORE_COUNTER DW 0 ; SCORE IS INCREASED EVERY 5 FRAMES
	SCORE_INCREMENT_CONDITION DW 5; DETERMINES AFTER HOW MANY FRAMES THE SCORE SHOUD GET INCREASED

	BUFFER DB 5 DUP(?) ; MAXIMUM SCORE IS 65535
	BUFFER_SIZE DW 0

	COLOR DB 00H ; WHITE: 0FH, BLACK: 00H, GREEN: 0AH, BLUE: 0BH, RED: 0CH

	ROW DB 0 ; ROW OF THE CURSOR
	COLUMN DB 0 ; COLUMN OF THE CURSOR

	MAIN_MENU_INDEX DB 0
	MAIN_MENU_TITLE DB "- FLAPPY BIRD -$"
	MAIN_MENU_ITEM_0 DB "PLAY$"
	MAIN_MENU_ITEM_1 DB "ABOUT US$"
	MAIN_MENU_ITEM_2 DB "EXIT$"

	GAME_OVER_INDEX DB 0
	GAME_OVER_TITLE DB "THE GAME IS OVER!$"
	GAME_OVER_ITEM_1 DB "ENTER TO CONTINUE$"
	GAME_OVER_ITEM_2 DB "SCORE: $"
	
	GAME_MODE DB 0 ; 0: MAIN MENU, 1: GAME ITSELF, 2: PAUSE SCREEN, 3: GAME OVER, 4: ABOUT_US PAGE
	
	ABOUT_US_LINE_1 DB "- TEAM MEMBERS -$" 
	ABOUT_US_LINE_2 DB "SHAYAN KEBRITI & ERFAN ABEDI$"
	ABOUT_US_ITEM_0 DB "OK!$"

.CODE
	MAIN PROC FAR
		MOV AX, @DATA
		MOV DS, AX ; NOW DS REGISTER HAS THE ADDRES OF DATA SEGMENT
		
		MOV AH, 03H ; SETTING THE KEYBOARD SPEED TO FASTEST
		MOV AL, 05H
		MOV BL, 05H
		MOV BH, 00H
		INT 16H

		; CALCULATING GRAVITY_COUNTER_CONDITION BASED ON GRAVITY_ACC
		MOV AX, 100
		MOV DX, 0
		DIV GRAVITY_ACC
		MOV GRAVITY_COUNTER_CONDITION, AX ; = (100 / GRAVITY_ACC)
		; ----------------------------------------------------------


		MOV AX, 20 ; X SECTIONS SIZE
		MOV DX, 0
		DIV BARRIERS_SPEED
		MOV BARRIER_ADD_NEW_CONDITION, AX

		; CALCULATING BALL_JUMP_CONDITION BASED ON BALL_JUMP_ACC
		;MOV AX, 100
		;MOV DX, 0
		;DIV BALL_JUMP_ACC
		;MOV BALL_JUMP_CONDITION, AX ; = (100 / BALL_JUMP_ACC)
		;MUL AX, BALL_JUMP
		; ----------------------------------------------------------


		CALL CLEAR_SCREEN
		
		CHECK_TIME:
			MOV AH, 2CH
			INT 21H
			
			CMP FPS_CONTROLLER, DL
			JZ CHECK_TIME
			MOV FPS_CONTROLLER, DL
			
			CMP GAME_MODE, 0
			JE GAME_MODE_0
			CMP GAME_MODE, 1
			JE GAME_MODE_1
			CMP GAME_MODE, 2
			JE GAME_MODE_2
			CMP GAME_MODE, 3
			JE GAME_MODE_3
			JMP GAME_EXIT
			
			GAME_MODE_0:
			
			CALL PRINT_MAIN_MENU
			CALL CHECK_MAIN_MENU
			JMP GAME_MODE_DEFAULT
			
			GAME_MODE_1:

				MOV COLOR, 00H ; COLOR BLACK
				CALL DRAW_BALL ; CLEARING THE BALL
			
				CALL MOVE_BALL
			
				MOV COLOR, 0BH ; COLOR BLUE
				CALL DRAW_BALL

				MOV COLOR, 0CH ; COLOR RED
				CALL DRAW_BARRIERS
			
				MOV COLOR, 0FH
				MOV ROW, 1
				MOV COLUMN, 98
				CALL PRINT_SCORE

				CALL DRAW_BORDERS

				CALL CHECK_GAME_PLAY
				JMP GAME_MODE_DEFAULT
		
			GAME_MODE_2:
				CALL PRINT_GAME_OVER
				CALL CHECK_GAME_OVER
				JMP GAME_MODE_DEFAULT
				
			GAME_MODE_3:
				CALL PRINT_ABOUT_US
				CALL CHECK_ABOUT_US
				JMP GAME_MODE_DEFAULT

				
			GAME_MODE_DEFAULT:
				JMP CHECK_TIME
			
		
		GAME_EXIT:
			MOV AH, 4CH
			INT 21H
	MAIN ENDP
	

	DRAW_BORDERS PROC NEAR
		MOV COLOR, 0FH ; COLOR WHITE
		MOV ROW, 20
		MOV COLUMN, 0
		CALL DRAW_HORIZANTAL_LINE

		MOV COLOR, 0FH ; COLOR WHITE
		MOV ROW, 180
		MOV COLUMN, 0
		CALL DRAW_HORIZANTAL_LINE
		RET
	DRAW_BORDERS ENDP

	CLEAR_SCREEN PROC NEAR
	
		MOV AH, 00H ; INTERRUPT FOR SETTING THE VIDEO MODE
		MOV AL, 13H ; SPECIFING THE VIDEO MODE AS 320 * 200 256 COLOR GRAPHICS (MCGA, VGA)
		INT 10H ; CALLING THE INTERRUPT
		MOV AH, 0BH ; INTERRUPT FOR SETTING THE BACKGROUND COLOR
		MOV BH, 00H
		MOV BL, 00H ; WE WANT A BLACK BACKGROUND
		INT 10H ; CALLING THE INTERRUPT
		
		RET
	CLEAR_SCREEN ENDP


	MOVE_BALL PROC NEAR
		CALL MOVE_BARRIERS
		
		INC GRAVITY_COUNTER
		MOV CX, GRAVITY_COUNTER_CONDITION
		CMP GRAVITY_COUNTER, CX
		JL AFTER_GRAVITY_CHECKING
		MOV GRAVITY_COUNTER, 0
		
		DEC BALL_SPEED

		AFTER_GRAVITY_CHECKING:

		MOV CX, BALL_SPEED		
		SUB BALL_POS_Y, CX

		CALL CHECK_HIT
		
		PUSH AL
		CALL RECEIVE_JUMP
		CMP AL, 'J'
		POP AL
		JE ENTER_KEY_PRESSED
		RET
		
		ENTER_KEY_PRESSED:
			MOV CX, BALL_JUMP_ACC
			ADD BALL_SPEED, CX
			MOV CX, BALL_JUMP_FORCE_DURATION
			CMP FORCE_DURATION_COUNTER, 0
			JE READ_AND_MOVE_UP
			INC FORCE_DURATION_COUNTER
			RET
			READ_AND_MOVE_UP:
			RET
		FINISH_MOVE_BALL:
		MOV FORCE_DURATION_COUNTER, 0
		RET
	MOVE_BALL ENDP
	
	CHECK_HIT PROC NEAR
		MOV AL, BARRIER_QUEUE_REAR
		MOV DX, BALL_POS_Y
		CMP DX, 31 ; CHECK IF THE BALL HIT THE CEILING
		JLE CHECK_HIT_GAME_OVER
		CMP DX, 175
		JL CHECK_HIT_FOR ; CHECKING IF THE BALL HAS HIT THE GROUND
		;MOV BALL_POS_Y, 175
		JMP CHECK_HIT_GAME_OVER
		RET
		CHECK_HIT_GAME_OVER:
		MOV GAME_OVER, 1
		; ARM TODO: GAME OVER IS UPDATED HERE
		CALL TRANSMIT_STATE
		RET
		CHECK_HIT_FOR: ; FOR LOOP WHICH ITERATES BETWEEN BARRIERS AND CHECKS IF THE BALL HAS HITD TO ANY OF THEM
			CMP AL, BARRIER_QUEUE_FRONT
			JE CHECK_HIT_AFTER
			INC AL

			; CALCULATING BARRIER_QUEUE INDEX
			MOV AH, 00H
			MOV CL, 16
			DIV CL
			MOV AL, AH
			MOV AH, 00H
			MOV SI, AX
			SHL SI, 1 ; EXPLAINED IN ADD_FRONT FUNCTION
			; ------------------------

			; SETTING CURRENT BARRIER_HEIGHT
			MOV BX, OFFSET BARRIER_QUEUE_HEIGHT
			MOV CX, [BX][SI] ; CX = BARRIER_QUEUE_X[REAR + 1]
			MOV BARRIER_HEIGHT, CX
			; -----------------------------

			; CX = CURRENT BARRIER_X
			MOV BX, OFFSET BARRIER_QUEUE_X
			MOV CX, [BX][SI] ; CX = BARRIER_QUEUE_X[REAR + 1]
			; -----------------------------

			;PUSH CX ; BACKUP CX FOR FURTHOR USE
			MOV DX, BALL_POS_X
			ADD DX, BALL_SIZE
			CMP DX, CX
			JNE NOT_HIT

			; CX = CURRENT BARRIER_Y
			MOV BX, OFFSET BARRIER_QUEUE_Y
			MOV CX, [BX][SI] ; CX = BARRIER_QUEUE_Y[REAR + 1]
			; ----------------------------

			;PUSH CX ; BACKUP CX FOR FURTHOR USE
			MOV DX, BALL_POS_Y

			SUB CX, BALL_SIZE
			CMP DX, CX
			JL NOT_HIT

			;POP CX ; USE BACKUPED CX
			MOV BX, BARRIER_HEIGHT
			ADD CX, BX
			ADD CX, BALL_SIZE
			CMP DX, CX
			JG NOT_HIT

			JMP CHECK_HIT_GAME_OVER
			RET
			NOT_HIT:
				JMP CHECK_HIT_FOR
		CHECK_HIT_AFTER:
		RET
	CHECK_HIT ENDP
	

	MOVE_BARRIERS PROC NEAR
		MOV COLOR, 00H ; FIRST, LETS CLEAR BARRIERS FROM THE SCREEN
		CALL DRAW_BARRIERS

		INC SCORE_COUNTER
		MOV CX, SCORE_INCREMENT_CONDITION
		CMP SCORE_COUNTER, CX
		JL AFTER_SCORE_CALC
		MOV SCORE_COUNTER, 0
		INC SCORE
		; ARM TODO: SCORE IS UPDATED HERE
		CALL TRANSMIT_STATE
		AFTER_SCORE_CALC:

		; --- DECIDING TO ADD A NEW BARRIER OR NOT ---
		INC BARRIER_ADD_NEW_COUNTER
		MOV CX, BARRIER_ADD_NEW_CONDITION
		CMP BARRIER_ADD_NEW_COUNTER, CX 
		JL AFTER_BARRIER_ADD_NEW_CALC
		MOV BARRIER_ADD_NEW_COUNTER, 0

		CALL GEN_RANDOM
		MOV AX, RANDOM_NUMBER
		MOV BX, 2         
		MUL BX       ; (r*RANDOM_NUMBER/m) GIVES A BETTER RESULT THAN X MOD r (EXPLAINED IN REPORT)
		AND DX, 01H  
		JE AFTER_BARRIER_ADD_NEW_CALC  ; THE ALGORITHM SHOULDN'T PUT ANY BARRIERS INTO THIS SECTION

		CALL GEN_RANDOM_BARRIER_HEIGHT
		MOV DX, RANDOM_NUMBER
		MOV BARRIER_HEIGHT, DX

		CALL GEN_RANDOM_BARRIER_POS_Y
		MOV AX, RANDOM_NUMBER
		MOV BARRIER_POS_Y, AX

		MOV BARRIER_POS_X, 380 ; 320 + 60 (BALL X OFFSET)

		CALL ADD_FRONT ; ADDING THE NEW ELEMENT TO THE QUEUE
		; ----------------------------------------------
		AFTER_BARRIER_ADD_NEW_CALC:

		MOV AL, BARRIER_QUEUE_REAR
		MOV BX, OFFSET BARRIER_QUEUE_X
		
		MOVE_BARRIERS_FOR:
			CMP AL, BARRIER_QUEUE_FRONT
			JE MOVE_BARRIERS_AFTER
			INC AL
			MOV AH, 00H
			MOV DL, 16
			DIV DL
			MOV AL, AH
			MOV AH, 00H
			MOV SI, AX
			SHL SI, 1
			MOV DX, [BX][SI]
			MOV CX, BARRIERS_SPEED ; SPEED OF BARRIERS
			SUB DX, CX ; MOVE LEFT
			MOV [BX][SI], DX
			

			ADD DX, BARRIER_WIDTH ; CHECKING IF BARRIERS HAS REACHED THE END (LEFT)
			CMP DX, 0
			JG DONT_DEL_REAR
			CALL DEL_REAR
			MOV AL, BARRIER_QUEUE_REAR
			DONT_DEL_REAR:

			JMP MOVE_BARRIERS_FOR
			
		MOVE_BARRIERS_AFTER:
		RET
	MOVE_BARRIERS ENDP
	

	DRAW_BALL PROC NEAR
		MOV AH, 0CH ; INTERRUPT FOR WRITING A SINGLE PIXEL ON THE SCREEN

		MOV DX, BALL_POS_Y ; GET A COPY OF BALL_POS_Y
		MOV SI, 0 ; THE FIRST LOOP COUNTER
		DRAW_FOR_1: ; FOR LOOP WHICH ITERATES BETWEEN ROWS
			CMP SI, BALL_SIZE
			JAE DRAW_FOR_1_AFTER
			MOV CX, BALL_POS_X ; GET A COPY OF BALL_POS_X
			MOV DI, 0 ; THE SECOND LOOP COUNTER
			DRAW_FOR_2: ; FOR LOOP WHICH DRAWS A SINGLE ROW
				CMP DI, BALL_SIZE
				JAE DRAW_FOR_2_AFTER
				MOV AL, COLOR ; SPECIFYING COLOR OF THE PIXEL
				MOV BH, 00H ; SELECTING THE PAGE NUMBER
				INT 10H ; CALLING THE INTERRUPT
				INC DI
				INC CX
				JMP DRAW_FOR_2
			DRAW_FOR_2_AFTER:
			INC SI
			INC DX
			JMP DRAW_FOR_1
		DRAW_FOR_1_AFTER:
		
		CALL DRAW_CIRCLE ; THIS FUNCTION MAKES THE BALL MORE LIKE A CIRCLE
		RET
	DRAW_BALL ENDP
	

	DRAW_CIRCLE PROC NEAR
		MOV AH, 0CH
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV AL, COLOR
		MOV BH, 00H
		MOV SI, 02H
		DEC DX
		DRAW_CIRCLE_UPPER_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_UPPER_1_AFTER 
			INC CX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_UPPER_1_FOR
		DRAW_CIRCLE_UPPER_1_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		ADD DX, BALL_SIZE
		DRAW_CIRCLE_LOWER_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_LOWER_1_AFTER
			INC CX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_LOWER_1_FOR
		DRAW_CIRCLE_LOWER_1_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		DEC CX
		DRAW_CIRCLE_LEFT_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_LEFT_1_AFTER
			INC DX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_LEFT_1_FOR
		DRAW_CIRCLE_LEFT_1_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		ADD CX, BALL_SIZE
		DRAW_CIRCLE_RIGHT_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_RIGHT_1_AFTER
			INC DX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_RIGHT_1_FOR
		DRAW_CIRCLE_RIGHT_1_AFTER:
		RET
	DRAW_CIRCLE ENDP 


	GEN_RANDOM_BARRIER_HEIGHT PROC NEAR ; GENEREATES A RANDOM NUMBER BETWEEN 10 TO 50
		MOV RANDOM_RANGE, 5
		CALL GEN_RANDOM_WITH_RANGE
		ADD DX, 1
		MOV AX, 10
		MUL DX
		MOV RANDOM_NUMBER, AX
		RET
	GEN_RANDOM_BARRIER_HEIGHT ENDP


	GEN_RANDOM_BARRIER_POS_Y PROC NEAR ; RANDOM COLUMN NUMBER GENERATED FOR INIT_BARRIER_QUEUE
									   ; GENERATES A NUMBER BETWEEN [20, 180)
		MOV DX, 160
		SUB DX, BARRIER_HEIGHT
		MOV RANDOM_RANGE, DX
		CALL GEN_RANDOM_WITH_RANGE
		ADD DX, 20
		MOV RANDOM_NUMBER, DX
		RET
	GEN_RANDOM_BARRIER_POS_Y ENDP


	GEN_RANDOM_WITH_RANGE PROC NEAR ; RETURNS DX = RANDOM NUMBER FROM [0, RANDOM_RANGE) RANGE
		CALL GEN_RANDOM
		MOV  AX, RANDOM_NUMBER
		MOV BX, RANDOM_RANGE            
		MUL BX  ; (r*RANDOM_NUMBER/m) GIVES A BETTER RESULT THAN X MOD r (EXPLAINED IN REPORT)
		MOV RANDOM_NUMBER, DX
		RET 
	GEN_RANDOM_WITH_RANGE  ENDP


	GEN_RANDOM PROC NEAR ; THE MAIN RANDOM GERNERATOR METHOD
		MOV AX, 25173 ; LCG MULTIPLIER
		MUL LCG_SEED ; DX:AX = LCG MULTIPLIER * SEED
		ADD AX, 13849 ; ADD LCG INCREMENT VALUE
		; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
		MOV LCG_SEED, AX
		MOV RANDOM_NUMBER, AX ; THE MODULO VALUE IS 65536 (2^16) SO THE RESULT OF ADDITION IS ENOUGH
		RET 
	GEN_RANDOM ENDP
	

	ADD_FRONT PROC NEAR
		MOV AL, BARRIER_QUEUE_FRONT ; CHECK IF THE QUEUE IS FULL
		INC AL
		MOV AH, 00H
		MOV CL, 16
		DIV CL
		MOV AL, AH
		CMP AL, BARRIER_QUEUE_REAR
		JE QUEUE_FULL
		MOV AH, 00H ; (FRONT + 1) % SIZE
		MOV AL, BARRIER_QUEUE_FRONT 
		INC AX
		MOV CL, 16
		DIV CL ; AH CONTAINS THE (FRONT + 1) % SIZE
		MOV BARRIER_QUEUE_FRONT, AH ; UPDATING BARRIER_QUEUE_FRONT
		MOV BX, OFFSET BARRIER_QUEUE_X ; ADDING THE NEW ELEMENT IN QUEUE[ (FRONT + 1) % SIZE ]
		MOV AL, BARRIER_QUEUE_FRONT
		MOV AH, 00
		MOV SI, AX
		SHL SI, 1 ; BARRIER_POS_X AND BARRIER_POS_Y ARE 16 BIT VARIABLES (2 BYTES)
				  ; SINCE MEMORY IS BYTE ADDRESSABLE, AND EACH WORD IS 2 BYTES,
				  ; VALUES SHOULD BE WRITTEN IN ADDRESSES SEPRARTED BY 2 (EG BS + 00, BS + 02, BS + 04 )
		MOV AX, BARRIER_POS_X
		MOV [BX][SI], AX ; ADD POS_X FIELD

		MOV BX, OFFSET BARRIER_QUEUE_Y
		MOV AX, BARRIER_POS_Y
		MOV [BX][SI], AX ; ADD POS_Y FIELD

		MOV BX, OFFSET BARRIER_QUEUE_HEIGHT
		MOV AX, BARRIER_HEIGHT
		MOV [BX][SI], AX ; ADD BARRIER_HEIGHT FIELD
		QUEUE_FULL:
		RET
	ADD_FRONT ENDP
		

	DEL_REAR PROC NEAR
		MOV AL, BARRIER_QUEUE_REAR ; CHECKING IF THE QUEUE IS EMPTY
		MOV AH, BARRIER_QUEUE_FRONT ; IF THE FRONT AND REAR WERE AT THE SAME POSITION, THEN, THE QUEUE IS FULL
		CMP AL, AH
		JE QUEUE_EMPTY
		MOV AH, 00H ; NOW LETS CALCULATE (REAR + 1) % SIZE
		INC AX
		MOV CL, 16
		DIV CL ; AH CONTAINS THE (REAR + 1) % SIZE
		MOV BARRIER_QUEUE_REAR, AH ; UPDATING BARRIER_QUEUE_FRONT
		QUEUE_EMPTY:
		RET
	DEL_REAR ENDP
	

	INIT_BARRIER_QUEUE PROC NEAR
		MOV CX, 60
		INIT_BARRIER_FOR:
			CMP CX, 380 ; 320 + 60 FOR TOTAL QUEUE 
			JGE INIT_BARRIER_AFTER
			PUSH CX
			CALL GEN_RANDOM
			MOV AX, RANDOM_NUMBER
			MOV BX, 2         
			MUL BX       ; (r*RANDOM_NUMBER/m) GIVES A BETTER RESULT THAN X MOD r (EXPLAINED IN REPORT)
			AND DX, 01H  
			JE DONT_PUT_BARRIER  ; THE ALGORITHM SHOULDN'T PUT ANY BARRIERS INTO THIS SECTION

			CALL GEN_RANDOM_BARRIER_HEIGHT
			MOV DX, RANDOM_NUMBER
			MOV BARRIER_HEIGHT, DX

			CALL GEN_RANDOM_BARRIER_POS_Y
			MOV AX, RANDOM_NUMBER
			MOV BARRIER_POS_Y, AX

			POP CX
			MOV BARRIER_POS_X, CX
			PUSH CX

			CALL ADD_FRONT ; ADDING THE NEW ELEMENT TO THE QUEUE
			DONT_PUT_BARRIER:
				POP CX
				ADD CX, 20
				JMP INIT_BARRIER_FOR
	     
		INIT_BARRIER_AFTER:
			RET
	INIT_BARRIER_QUEUE ENDP
	
	
	DRAW_BARRIERS PROC NEAR
		MOV AL, BARRIER_QUEUE_REAR
		DRAW_BARRIERS_WHILE: ; WHILE (REAR != FRONT) -> CONTINUE DRAWING BARRIERS
			CMP AL, BARRIER_QUEUE_FRONT
			JE DRAW_BARRIERS_AFTER
			INC AL
			MOV AH, 00H ; CALCULATING (REAR + 1) % SIZE
			MOV CL, 16
			DIV CL
			MOV AL, AH ; AH = (REAR + 1) % SIZE
			MOV AH, 00H ; MAKING A 16 BIT VERSION OF AL
			MOV SI, AX
			SHL SI, 1 ; EXPLAINED IN ADD_FRONT
			MOV BX, OFFSET BARRIER_QUEUE_X ; SETTING INPUTS FOR FUNCTION DRAW_SINGLE_BARRIER
			MOV DX, [BX][SI]
			MOV BARRIER_POS_X, DX
			CMP DX, 320
			JGE DRAW_BARRIERS_AFTER
			MOV BX, OFFSET BARRIER_QUEUE_Y
			MOV DX, [BX][SI]
			MOV BARRIER_POS_Y, DX
			MOV BX, OFFSET BARRIER_QUEUE_HEIGHT
			MOV DX, [BX][SI]
			MOV BARRIER_HEIGHT, DX
			PUSH CX
			PUSH AX
			CALL DRAW_SINGLE_BARRIER ; CALLING PROCEDURE WHICH DRAWS A SINGLE BARRIER
			POP AX
			POP CX
			JMP DRAW_BARRIERS_WHILE
			
		DRAW_BARRIERS_AFTER:
		RET
	DRAW_BARRIERS ENDP
	
	
	DRAW_SINGLE_BARRIER PROC NEAR
		MOV AH, 0CH ; INTERRUPT FOR WRITING A SINGLE PIXEL ON THE SCREEN
		MOV DX, BARRIER_POS_Y
		MOV SI, 00H  ; THE FIRST LOOP COUNTER
		DRAW_SINGLE_BARRIER_FOR_1: ; FOR LOOP WHICH ITERATES BETWEEN ROWS
			CMP SI, BARRIER_HEIGHT
			JE DRAW_SINGLE_BARRIER_AFTER_1
			MOV CX, BARRIER_POS_X
			MOV DI, 00H ; THE SECOND LOOP COUNTER
			DRAW_SINGLE_BARRIER_FOR_2: ; FOR LOOP WHICH DRAWS A SINGLE ROW
				CMP DI, BARRIER_WIDTH 
				JE DRAW_SINGLE_BARRIER_AFTER_2
				MOV AL, COLOR ; SPECIFYING THE COLOR OF PIXEL
				MOV BH, 00H
				INT 10H ; CALLING THE INTERRUPT
				INC DI
				INC CX
				JMP DRAW_SINGLE_BARRIER_FOR_2
			DRAW_SINGLE_BARRIER_AFTER_2:
				INC SI
				INC DX
				JMP DRAW_SINGLE_BARRIER_FOR_1
		DRAW_SINGLE_BARRIER_AFTER_1:
			
		RET
	DRAW_SINGLE_BARRIER ENDP


	DRAW_HORIZANTAL_LINE PROC NEAR
		MOV AH, 0CH ; INTERRUPT FOR WRITING A SINGLE PIXEL ON THE SCREEN
		MOV DH, 0
		MOV DL, ROW
		MOV SI, 00H  ; THE FIRST LOOP COUNTER
		DRAW_HORIZANTAL_LINE_FOR_1: ; FOR LOOP WHICH ITERATES BETWEEN ROWS
			CMP SI, 2
			JE DRAW_HORIZANTAL_LINE_AFTER_1
			MOV CH, 0
			MOV CL, COLUMN
			MOV DI, 00H ; THE SECOND LOOP COUNTER
			DRAW_HORIZANTAL_LINE_FOR_2: ; FOR LOOP WHICH DRAWS A SINGLE ROW
				CMP DI, SCREEN_WIDTH 
				JE DRAW_HORIZANTAL_LINE_AFTER_2
				MOV AL, COLOR ; SPECIFYING THE COLOR OF PIXEL
				MOV BH, 00H
				INT 10H ; CALLING THE INTERRUPT
				INC DI
				INC CX
				JMP DRAW_HORIZANTAL_LINE_FOR_2
			DRAW_HORIZANTAL_LINE_AFTER_2:
				INC SI
				INC DX
				JMP DRAW_HORIZANTAL_LINE_FOR_1
		DRAW_HORIZANTAL_LINE_AFTER_1:
		RET
	DRAW_HORIZANTAL_LINE ENDP
	

	CHECK_GAME_PLAY PROC NEAR
		CMP GAME_OVER, 1
		JNE GAME_NOT_OVER
		CALL CLEAR_SCREEN
		MOV GAME_OVER_INDEX, 0
		MOV GAME_MODE, 2
		RET
		GAME_NOT_OVER:
		RET
	CHECK_GAME_PLAY ENDP
	

	PRINT_SCORE PROC NEAR
		CALL SPLIT_SCORE_BUFFER
		
		PRINT_SCORE_PRNT:
			MOV SI, BUFFER_SIZE ; i = n
			SUB SI, 1
			MOV DH, ROW
			MOV DL, COLUMN
			MOV BH, 00H
			PRINT_SCORE_FOR:
				INC DL
				MOV AH, 02H
				INT 10H
				CMP SI, 0
				JL PRINT_SCORE_EXIT
				MOV BX, OFFSET BUFFER
				MOV AL, [BX][SI]
				MOV BH, 00H
				MOV BL, COLOR
				MOV AH, 09H
				MOV CX, 1
				INT 10H
				SUB SI, 1
				JMP PRINT_SCORE_FOR
		PRINT_SCORE_EXIT:
		RET	
	PRINT_SCORE ENDP
	

	SPLIT_SCORE_BUFFER PROC NEAR ; THIS FUNCTION SPLITS THE SCORE INTO DIGITS CHARACTERS
		MOV BX, OFFSET BUFFER
		MOV BUFFER_SIZE, 0
		MOV DX, SCORE
		MOV CX, 10
		SPLIT_SCORE_DO_WHILE:   	; DO {
			MOV AX, DX				;
			MOV DX, 00H				;
			DIV CX					;	SCORE = SCORE % 10;
			MOV SI, BUFFER_SIZE 	;	
			ADD DL, '0'				;
			MOV [BX][SI], DL		;	PUSH(SCORE);
			MOV DX, AX 				;
			ADD BUFFER_SIZE, 1		;
			CMP DX, 0				;
			JZ SPLIT_SCORE_AFTER	;
			JMP SPLIT_SCORE_DO_WHILE; } WHILE (SCORE != 0);
        
		SPLIT_SCORE_AFTER:
		RET
	SPLIT_SCORE_BUFFER ENDP
	

	CHECK_MAIN_MENU PROC NEAR
		MOV AH, 01H
		INT 16H
		JZ CHECK_MAIN_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 'W'
		JE MAIN_INDEX_UP
		CMP AL, 'w'
		JE MAIN_INDEX_UP
		CMP AL, 'S'
		JE MAIN_INDEX_DOWN
		CMP AL, 's'
		JE MAIN_INDEX_DOWN
		CMP AL, 0DH ; ENTER KEY
		JE MAIN_ENTER
		RET
		
		MAIN_ENTER:
			CMP MAIN_MENU_INDEX, 0
			JE MAIN_ITEM_0
			CMP MAIN_MENU_INDEX, 1
			JE MAIN_ITEM_1
			CMP MAIN_MENU_INDEX, 2
			JE MAIN_ITEM_2
			RET
			
			MAIN_ITEM_0:
				CALL CLEAR_SCREEN
				CALL INIT_GAME
				MOV GAME_MODE, 1
				RET
			
			MAIN_ITEM_1:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 3
				RET
				
			MAIN_ITEM_2:
				CALL EXIT_GAME
				RET

		MAIN_INDEX_UP:
		MOV AL, MAIN_MENU_INDEX
		DEC AL
		CMP AL, 0
		JGE SET_MENU_INDEX
		ADD AL, 3

		SET_MENU_INDEX:
		MOV MAIN_MENU_INDEX, AL
		RET

		MAIN_INDEX_DOWN:
		MOV AL, MAIN_MENU_INDEX
		INC AL
		MOV CL, 3
		MOV AH, 00H
		DIV CL
		MOV MAIN_MENU_INDEX, AH
		RET
		
		CHECK_MAIN_RET:
		RET
	CHECK_MAIN_MENU ENDP
	

	PRINT_MAIN_MENU PROC NEAR
		MOV ROW, 4
		MOV COLUMN, 12

		MOV BX, OFFSET MAIN_MENU_TITLE
		MOV COLOR, 0FH
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 0
		JNE MAIN_MENU_ITEM_0_WHITE
		MOV COLOR, 0AH
		JMP MAIN_MENU_PRINT_ITEM_0
		MAIN_MENU_ITEM_0_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_0:
		MOV BX, OFFSET MAIN_MENU_ITEM_0
		ADD ROW, 6
		MOV COLUMN, 17
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 1
		JNE MAIN_MENU_ITEM_1_WHITE
		MOV COLOR, 0AH
		JMP MAIN_MENU_PRINT_ITEM_1
		MAIN_MENU_ITEM_1_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_1:
		MOV BX, OFFSET MAIN_MENU_ITEM_1
		ADD ROW, 5
		MOV COLUMN, 15
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 2
		JNE MAIN_MENU_ITEM_2_WHITE
		MOV COLOR, 0AH
		JMP PRINT_MAIN_MENU_ITEM2
		MAIN_MENU_ITEM_2_WHITE:
		MOV COLOR, 0FH
		PRINT_MAIN_MENU_ITEM2:
		MOV BX, OFFSET MAIN_MENU_ITEM_2
		ADD ROW, 5
		MOV COLUMN, 17
		CALL PRINT_STRING
		RET
	PRINT_MAIN_MENU ENDP
	
	
	CHECK_GAME_OVER PROC NEAR
		MOV AH, 01H
		INT 16H
		JZ CHECK_GAME_OVER_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 'W'
		JE GAME_OVER_INDEX_UP
		CMP AL, 'w'
		JE GAME_OVER_INDEX_UP
		CMP AL, 'S'
		JE GAME_OVER_INDEX_DOWN
		CMP AL, 's'
		JE GAME_OVER_INDEX_DOWN
		CMP AL, 0DH
		JE GAME_OVER_ENTER
		RET
		
		GAME_OVER_ENTER:
			CMP GAME_OVER_INDEX, 0
			JE CHECK_GAME_OVER_ITEM_1
			RET
			
			CHECK_GAME_OVER_ITEM_1:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 0
				MOV MAIN_MENU_INDEX, 0
				RET
			
		GAME_OVER_INDEX_UP:
		MOV AL, GAME_OVER_INDEX
		DEC AL
		CMP AL, 0
		JGE SET_GAME_OVER_INDEX
		ADD AL, 1
		SET_GAME_OVER_INDEX:
		MOV GAME_OVER_INDEX, AL
		RET
		GAME_OVER_INDEX_DOWN:
		MOV AL, GAME_OVER_INDEX
		INC AL
		MOV CL, 1
		MOV AH, 00H
		DIV CL
		MOV GAME_OVER_INDEX, AH
		RET
		
		CHECK_GAME_OVER_RET:
		RET
	CHECK_GAME_OVER ENDP
	
	PRINT_GAME_OVER PROC NEAR
		MOV ROW, 5
		MOV COLUMN, 10
		MOV BX, OFFSET GAME_OVER_TITLE
		MOV COLOR, 0FH
		CALL PRINT_STRING
		
		MOV COLOR, 0BH
		MOV BX, OFFSET GAME_OVER_ITEM_2
		ADD ROW, 7
		MOV COLUMN, 14
		CALL PRINT_STRING
		CALL PRINT_SCORE
		
		CMP GAME_OVER_INDEX, 0
		JNE GAME_OVER_ITEM_1_WHITE
		MOV COLOR, 0AH
		JMP PRINT_GAME_OVER_ITEM_0
		GAME_OVER_ITEM_1_WHITE:
		MOV COLOR, 0FH
		PRINT_GAME_OVER_ITEM_0:
		MOV BX, OFFSET GAME_OVER_ITEM_1
		ADD ROW, 33
		MOV COLUMN, 2
		CALL PRINT_STRING

		RET
	PRINT_GAME_OVER ENDP
	
	CHECK_ABOUT_US PROC NEAR
		MOV AH, 01H
		INT 16H
		JZ CHECK_ABOUT_US_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 0DH ; ASCII CODE FOR ENTER KEY
		JNE CHECK_ABOUT_US_RET
		CALL CLEAR_SCREEN
		MOV GAME_MODE, 0
		
		CHECK_ABOUT_US_RET:
		RET
	CHECK_ABOUT_US ENDP
	
	PRINT_ABOUT_US PROC NEAR
		MOV ROW, 4
		MOV COLUMN, 11
		
		MOV BX, OFFSET ABOUT_US_LINE_1
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 8
		MOV COLUMN, 5
		
		MOV BX, OFFSET ABOUT_US_LINE_2
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 10
		MOV COLUMN, 5
		
		
		MOV BX, OFFSET ABOUT_US_ITEM_0
		MOV COLOR, 0AH
		MOV ROW, 20
		MOV COLUMN, 17
		CALL PRINT_STRING
		RET
	PRINT_ABOUT_US ENDP

	PRINT_STRING PROC NEAR ; THIS FUNCTION PRINTS A STRING IN A SPECIFIED POSITION WITH A SPECIFIED COLOR
		MOV SI, 0 
		MOV DH, ROW
		MOV DL, COLUMN
		
		PRINT_STRING_WHILE:
			MOV AL, [BX][SI]
			CMP AL, '$'
			JE PRINT_STRING_AFTER
			PUSH BX
			INC DL
			MOV AH, 02H
			MOV BH, 00H
			INT 10H
			MOV BH, 00H
			MOV BL, COLOR
			MOV CX, 1
			MOV AH, 09
			INT 10H
			INC SI
			POP BX
			JMP PRINT_STRING_WHILE
		PRINT_STRING_AFTER:
		MOV ROW, DH
		MOV COLUMN, DL
		RET
	PRINT_STRING ENDP
	
	
	INIT_GAME PROC NEAR
		MOV BALL_POS_X, 30  
		MOV BALL_POS_Y, 100 
		MOV SCORE, 0
		MOV GAME_OVER, 0
		MOV BALL_SPEED, -5
		MOV SCORE_COUNTER, 0
		MOV BARRIER_QUEUE_FRONT, 0
		MOV BARRIER_QUEUE_REAR, 0
		CALL INIT_BARRIER_QUEUE
		MOV GRAVITY_COUNTER, 0
		MOV FORCE_DURATION_COUNTER, 0
		; INITIALIZING THE RANDOM_NUMBER WITH SYSTEM TIME
		MOV AH, 00H 
		INT 1AH
		MOV LCG_SEED, DX
		; ------------------------------------------------
		MOV BARRIER_ADD_NEW_COUNTER, 0
		RET
	INIT_GAME ENDP
	

	EXIT_GAME PROC NEAR
		MOV AH, 00H ; RETURNING TO TEXT MODE
		MOV AL, 02H
		INT 10H
		MOV AH, 4CH
		INT 21H
	EXIT_GAME ENDP


	TRANSMIT_START PROC NEAR
		MOV AH, 00H ; INITIALIZE USART
		MOV AL, 00E3H ; BAUD RATE 9600, PARITY 0, STOP 1, WORD BITS LENGTH 8
		INT 14H
		
		MOV DX, 03F8H ; Select Serial1

		MOV AL, 'S'
		OUT DX, AL
		RET
	TRANSMIT_START ENDP


	TRANSMIT_STATE PROC NEAR
		MOV AH, 00H ; INITIALIZE USART
		MOV AL, 0E3H ; BAUD RATE 9600, PARITY 0, STOP 1, WORD BITS LENGTH 8
		MOV DX, 0; SELECT SERIAL1
		INT 14H

		MOV DX, 03F8H ; Select Serial1

		CMP GAME_OVER, 1
		JNE GAME_NOT_OVER_FLAG
		MOV AL, 'O'
		OUT DX, AL
		RET

		GAME_NOT_OVER_FLAG:
		MOV AL, 'P'
		OUT DX, AL
		RET
	TRANSMIT_STATE ENDP


	RECEIVE_JUMP PROC NEAR
		MOV AH, 00H ; INITIALIZE USART
		MOV AL, 0E3H ; BAUD RATE 9600, PARITY 0, STOP 1, WORD BITS LENGTH 8
		MOV DX, 0; SELECT SERIAL1
		INT 14H

		MOV DX, 03F8H ; Select Serial1
		IN AL, DX ; READ CHARACTER
		RET
	RECEIVE_JUMP ENDP
		END MAIN