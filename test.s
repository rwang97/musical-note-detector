.equ stack, 0x00400000
.equ ADDR_JP1, 0xFF200060
.equ ADDR_JP1_EDGE, 0xFF20006C
.equ JTAG_UART, 0xFF201000
.equ PS2_KEYBOARD, 0xff200100
.equ off, 0xFFDFFFFF
.equ onF, 0xFFDFFFFB
.equ onB, 0xFFDFFFF3
.equ PIXEL,0x08000000
.equ CHARACTER,0x09000000
.equ X_BOUND,319
.equ Y_BOUND,239
.equ STACK,0x00400000
.equ DO,21
.equ RUI,21
.equ MI,19
.equ FA,16
.equ SO,13
.equ LA,11
.equ XI,8
.equ FIRST_STAVE,40
.equ SECOND_STAVE,83
.equ THIRD_STAVE,126
.equ FOURTH_STAVE,169
.equ FIRST_BAR, 0
.equ SECOND_BAR, 64
.equ THIRD_BAR, 128
.equ FOURTH_BAR, 192
.equ FIFTH_BAR, 256
.equ FIRST_IN_BAR, 10
.equ SECOND_IN_BAR, 25
.equ THIRD_IN_BAR, 40
.equ FOURTH_IN_BAR, 55
.equ START_X, 233
.equ PLAY_X, 279
.equ NEW_X, 185
.equ MANUAL_X, 139
.equ FRAME_LEFT_Y, 218
.equ C, 46
.equ D, 41
.equ E, 36
.equ F, 34
.equ G, 30
.equ A, 27
.equ B, 24

.section .data
#detect what key user presses
key_pressed: .byte 's'
#keep track of what state the user is in
.align 2
STATE: .byte 0x00
.align 2
NOTE_NUM: .byte 0x00
.align 2
ONE_NOTE_DONE: .byte 0x01
.align 2
HAS_PRESSED_BEGIN: .byte 0x00
.align 2
READ_NUM_SO_FAR: .byte 0x00
.align 2
MANUAL_MODE_ON: .byte 0x00
.align 2
HAS_REACHED_FIRST_BLACK: .byte 0x00
.align 2
CURRENT_READING_NOTE: 
ONE: .byte 0x00
TWO: .byte 0x00
THREE: .byte 0x00
LAST: .byte 0x00
.align 2
Bar1: .space 80
#store the input character(keyboard version)
.align 2
KEYBOARD_BUFFER:
	.skip 256
.align 2
START_ASCII:
	.byte 0x5A
start_boolen:
	.byte 0x00

.section .text
.global _start

# r8 address of JP1
# r9 intermediate value
# r11 intermediate value
# r14 value reading from sensor 0
# r15 value reading from sensor 1
# sensor 4 as touch sensor, sensor 0, 1, 3 as light sensor

_start:	
#============================ Initialize ==============================

	#initialize everything including JP1, motors, sensors, JTAG_UART
	movia sp, stack
	call initialize
	call CLEAR_CHAR
	call FIRST_PAGE
	call TWINKLE
	call CLEAR_CHAR
	call CLEAR_SCREEN

#======================== main body of code ==========================
CHECK_MODE:
	movia r8, MANUAL_MODE_ON
	ldb r8, 0(r8)
	beq r8, r0, AUTO
	br MANUAL

#======================== Play subroutine ============================
PLAY:
	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off

	movia r8, key_pressed
	movui r9, 's'
	stb r9, 0(r8)

	movia r4, PLAY_X
	call HIGHLIGHT_RED

	movia r9, Bar1

PLAY_UNTIL_END:
	call Poll
	ldb r10, 0(r9)
	movi r11, 0x01
	beq r10, r11, PLAY_DO
	movi r11, 0x02
	beq r10, r11, PLAY_RE
	movi r11, 0x03
	beq r10, r11, PLAY_MI
	movi r11, 0x04
	beq r10, r11, PLAY_FA
	movi r11, 0x05
	beq r10, r11, PLAY_SO
	movi r11, 0x06
	beq r10, r11, PLAY_LA
	movi r11, 0x07
	beq r10, r11, PLAY_TI
	br EXIT_PLAY
PLAY_DO:
	movui r7, C
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_RE:
	movui r7, D
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_MI:
	movui r7, E
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_FA:
	movui r7, F
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_SO:
	movui r7, G
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_LA:
	movui r7, A
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
PLAY_TI:
	movui r7, B
	call Sound
	addi r9, r9, 1
	br PLAY_UNTIL_END
EXIT_PLAY:
	movia r4, PLAY_X
	call HIGHLIGHT_BLACK
	br CHECK_MODE

#========================== Manual Mode ==============================
MANUAL:
	movia r4, MANUAL_X
	call HIGHLIGHT_RED
MOVE_MOTOR_MANUAL:
	movui r10, 'd'
	movui r11, 'a'
	movui r12, 's'
	movui r13, 'r'
	movui r14, 'm'
	movui r15, 'c'
	movui r16, 'p'

	movia r8, ADDR_JP1
	movia r9, key_pressed
	ldb r9, (r9)
	beq r9, r10, MOVE_FORWARD_MANUAL
	beq r9, r11, MOVE_BACKWARD_MANUAL
	beq r9, r12, STOP_MOTOR_MANUAL
	beq r9, r13, RESET_MANUAL
	beq r9, r14, CHANGE_INTO_AUTO
	beq r9, r15, SCAN_MANUAL
	beq r9, r16, PLAY
	br MOVE_MOTOR_MANUAL

CHANGE_INTO_AUTO:
	# before change mode, stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	movia r8, key_pressed
	movui r9, 's'
	stb r9, 0(r8)

	#Store the mode state into global var
	movia r8, MANUAL_MODE_ON
	stb r0, 0(r8)
	br CHECK_MODE

#reset everything in the memory
RESET_MANUAL:
#reset state
	movia r9, STATE
	movi r10, 0x00
	stb r10, 0(r9)

	#reset NOTE_NUM
	movia r9, NOTE_NUM
	movi r10, 0x00
	stb r10, 0(r9)

	#reset boolean ONE_NOTE_DONE
	movia r9, ONE_NOTE_DONE
	movi r10, 0x01
	stb r10, 0(r9)

	#reset HAS_PRESSED_BEGIN
	movia r9, HAS_PRESSED_BEGIN
	movi r10, 0x00
	stb r10, 0(r9)	

	#reset READ_NUM_SO_FAR
	movia r9, READ_NUM_SO_FAR
	movi r10, 0x00
	stb r10, 0(r9)	

	#reset current note
	movia r9, CURRENT_READING_NOTE
	stW r0, 0(r9)	

	#reset reach first black
	movia r9, HAS_REACHED_FIRST_BLACK
	stb r0, 0(r9)

	#reset keyboard buffer
	movia r9, KEYBOARD_BUFFER
	movi r10, 256

CLEAR_BUFFER_LOOP_MANUAL:
	stb r0, 0(r9)
	addi r9, r9, 1
	addi r10, r10, -1
	bgt r10, r0, CLEAR_BUFFER_LOOP_MANUAL
	
	#reset bars in the memory
	movia r9, Bar1
	mov r10, r0

CLEAN_LOOP_MANUAL:
	#clean the bar memory
	movui r4, 20
	beq r10, r4, EXIT_LOOP_MANUAL
	stw r0, 0(r9)
	addi r9, r9, 4
	addi r10, r10, 1
	br CLEAN_LOOP_MANUAL
EXIT_LOOP_MANUAL:
	movia r9, key_pressed
	movui r10, 's'
	stb r10, 0(r9)

	#CLEAR start_boolean
	movia r9, start_boolen
	stb r0, 0(r9)
	call initialize
	
	#CLEAR start_boolean
	movia r9, start_boolen
	stb r0, 0(r9)
	call initialize

	call CLEAR_CHAR
	call FIRST_PAGE

	call TWINKLE
	call CLEAR_CHAR
	call CLEAR_SCREEN
	br CHECK_MODE

#turning on M0 Forward
MOVE_FORWARD_MANUAL:		
	movia r9, onF
	movia r8, ADDR_JP1
	stwio r9, 0(r8)

	movia r4, 300000
	call timer	
	#stop the motor
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off

	movia r4, 3000000
	call timer	
	br MOVE_MOTOR_MANUAL

#Basic motor moving
MOVE_BACKWARD_MANUAL:	
	movia r9, onB
	movia r8, ADDR_JP1
	stwio r9, 0(r8)

	movia r4, 300000
	call timer	
	#stop the motor
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off

	movia r4, 3000000
	call timer	
	br MOVE_MOTOR_MANUAL

STOP_MOTOR_MANUAL:
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	br MOVE_MOTOR_MANUAL

#==================== Read Sensor Manual Mode =====================
SCAN_MANUAL:
READ_SENSOR_MANUAL:

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	# change global variable to 'stop mode' 
	movia r8, key_pressed
	movui r9, 's'
	stb r9, 0(r8)

	movia r8, ADDR_JP1
	ldwio r9, (r8)
	srli r9, r9, 27
	andi r9, r9, 0x000F

CHECK_SENSOR_MANUAL:
	#check three sensors, 0, 1, 3
	andi r10, r9, 0x01
	bne r10, r0, READ_NOTE_MANUAL
	andi r10, r9, 0x02
	bne r10, r0, READ_NOTE_MANUAL
	andi r10, r9, 0x08
	bne r10, r0, READ_NOTE_MANUAL
	call WARNING_NULL
	br MOVE_MOTOR_MANUAL

READ_NOTE_MANUAL:
	call CLEAR_NULL
	#check state
	movia r8, STATE
	ldb r9, 0(r8)

LOAD_BAR_MANUAL:
	#depending on the state, load into corresponding bar
	#r8 is the base address of current bar
	muli r9, r9, 0x04
	movia r8, Bar1
	add r8, r8, r9	
	movia r9, NOTE_NUM
	ldb r9, 0(r9)
	add r8, r9, r8
	#check if current note number is over the bar
	movui r10, 0x03
	beq r9, r10, add_state_MANUAL # if note number == 3
	#if not over, add one note num
	movia r10, NOTE_NUM
	addi r9, r9, 0x01
	stb r9, 0(r10)
	br LOAD_ONE_NOTE_INTO_BAR_MANUAL

add_state_MANUAL:
	movia r10, NOTE_NUM
	movi r9, 0x00	
	stb r9, 0(r10)	# reset the note number
	movia r10, STATE
	ldb r9, 0(r10)
	addi r9, r9, 1 
	stb r9, 0(r10)  # add one to the state
	
LOAD_ONE_NOTE_INTO_BAR_MANUAL:
	#r10 as the sensor value
	movia r10, ADDR_JP1
	ldwio r10, (r10)
	srli r10, r10, 27
	andi r10, r10, 0x000B

	movui r11, 0b0001
	beq r10, r11, load_do_MANUAL
	movui r11, 0b0010
	beq r10, r11, load_re_MANUAL
	movui r11, 0b1000
	beq r10, r11, load_mi_MANUAL
	movui r11, 0b0011
	beq r10, r11, load_fa_MANUAL
	movui r11, 0b1001
	beq r10, r11, load_so_MANUAL
	movui r11, 0b1010
	beq r10, r11, load_la_MANUAL
	movui r11, 0b1011
	beq r10, r11, load_ti_MANUAL
	br MOVE_MOTOR_MANUAL

load_do_MANUAL:
	movui r10, 0x01
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, C
	call Sound

	br MOVE_MOTOR_MANUAL

load_re_MANUAL:
	movui r10, 0x02
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, D
	call Sound

	br MOVE_MOTOR_MANUAL

load_mi_MANUAL:
	movui r10, 0x03
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, E
	call Sound

	br MOVE_MOTOR_MANUAL

load_fa_MANUAL:
	movui r10, 0x04
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, F
	call Sound

	br MOVE_MOTOR_MANUAL

load_so_MANUAL:
	movui r10, 0x05
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, G
	call Sound

	br MOVE_MOTOR_MANUAL

load_la_MANUAL:
	movui r10, 0x06
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, A
	call Sound

	br MOVE_MOTOR_MANUAL

load_ti_MANUAL:
	movui r10, 0x07
	stb r10, 0(r8)

	mov r4, r10
	call PRINT_NOTE

	movui r7, B
	call Sound

	br MOVE_MOTOR_MANUAL
	
#=========================== AUTO Mode ===============================
AUTO:
	movia r4, MANUAL_X
	call HIGHLIGHT_BLACK
MOVE_MOTOR_AUTO:
	movui r10, 'd'
	movui r11, 'a'
	movui r12, 's'
	movui r13, 'b'
	movui r14, 'r'
	movui r15, 'm'
	movui r16, 'p'
	movia r8, ADDR_JP1
	movia r9, key_pressed
	ldb r9, (r9)
	beq r9, r10, MOVE_FORWARD_AUTO
	beq r9, r11, MOVE_BACKWARD_AUTO
	beq r9, r12, STOP_MOTOR_AUTO
	beq r9, r13, BEGIN_SCAN_AUTO
	beq r9, r14, RESET_AUTO
	beq r9, r15, CHANGE_INTO_MANUAL
	beq r9, r16, PLAY
	br READ_SENSOR_AUTO

CHANGE_INTO_MANUAL:
	movia r8, HAS_PRESSED_BEGIN
	ldb r8, 0(r8)
	beq r8, r0, CHANGE_MODE_AUTO 
	movia r8, key_pressed
	movui r9, 'd'
	stb r9, 0(r8)
	br MOVE_MOTOR_AUTO

CHANGE_MODE_AUTO:
	# before change mode, stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	movia r8, key_pressed
	movui r9, 's'
	stb r9, 0(r8)
	#Store the mode state into global var
	movia r8, MANUAL_MODE_ON
	movui r9, 1
	stb r9, 0(r8)
	br CHECK_MODE
	

#reset everything in the memory
RESET_AUTO:
	#reset state
	movia r9, STATE
	movi r10, 0x00
	stb r10, 0(r9)

	#reset NOTE_NUM
	movia r9, NOTE_NUM
	movi r10, 0x00
	stb r10, 0(r9)

	#reset boolean ONE_NOTE_DONE
	movia r9, ONE_NOTE_DONE
	movi r10, 0x01
	stb r10, 0(r9)

	#reset HAS_PRESSED_BEGIN
	movia r9, HAS_PRESSED_BEGIN
	movi r10, 0x00
	stb r10, 0(r9)	

	#reset READ_NUM_SO_FAR
	movia r9, READ_NUM_SO_FAR
	movi r10, 0x00
	stb r10, 0(r9)	

	#reset current note
	movia r9, CURRENT_READING_NOTE
	stw r0, 0(r9)	

	#reset reach first black
	movia r9, HAS_REACHED_FIRST_BLACK
	stb r0, 0(r9)
	
	#reset keyboard buffer
	movia r9, KEYBOARD_BUFFER
	movi r10, 256

CLEAR_BUFFER_LOOP:
	stb r0, 0(r9)
	addi r9, r9, 1
	addi r10, r10, -1
	bgt r10, r0, CLEAR_BUFFER_LOOP

	#reset bars in the memory
	movia r9, Bar1
	mov r10, r0

CLEAN_LOOP_AUTO:
	#clean the bar memory
	movui r4, 20
	beq r10, r4, EXIT_LOOP_AUTO
	stw r0, 0(r9)
	addi r9, r9, 4
	addi r10, r10, 1
	br CLEAN_LOOP_AUTO
EXIT_LOOP_AUTO:
	movia r9, key_pressed
	movui r10, 's'
	stb r10, 0(r9)

	#CLEAR start_boolean
	movia r9, start_boolen
	stb r0, 0(r9)
	call initialize
	
	#CLEAR start_boolean
	movia r9, start_boolen
	stb r0, 0(r9)
	call initialize

	call CLEAR_CHAR
	call FIRST_PAGE


	call TWINKLE
	call CLEAR_CHAR
	call CLEAR_SCREEN
	br CHECK_MODE
	
BEGIN_SCAN_AUTO:	
	movia r4, START_X
	call HIGHLIGHT_RED
	movia r9,  HAS_PRESSED_BEGIN
	movi r8, 0x01
	stb r8, 0(r9)

	#ldb r8, 0(r8)
	#beq r8, r0, MOVE_MOTOR_AUTO

	#reset boolean ONE_NOTE_DONE
	movia r9, ONE_NOTE_DONE
	movi r10, 0x01
	stb r10, 0(r9)

	#reset READ_NUM_SO_FAR
	movia r9, READ_NUM_SO_FAR
	movi r10, 0x00
	stb r10, 0(r9)	

	#reset current note
	movia r9, CURRENT_READING_NOTE
	stw r0, 0(r9)	

	#reset reach first black
	movia r9, HAS_REACHED_FIRST_BLACK
	stb r0, 0(r9)

	movia r9, key_pressed
	movui r10, 'd'
	stb r10, 0(r9)
	movia r4, 10000000
	call timer

GET_TO_START_POINT:
	movia r9, key_pressed
	ldb r9, (r9)
	movui r10, 's'
	beq r9, r10, START_MOVE_FORWARD #if it touches the touch sensor, begin moving forward
	movia r9, onB
	movia r8, ADDR_JP1
	stwio r9, (r8)
	movia r4, 400000
	call timer
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	movia r4, 3000000
	call timer		
	br GET_TO_START_POINT

START_MOVE_FORWARD:
	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off
	# wait for some time
	movia r4, 0x0EE6B280
	call timer
	movia r9, key_pressed
	movui r10, 'd'	#write forward key into the global variable so it's not 's' anymore
	stb r10, 0(r9)

	#move initial forward
	movia r9, onF
	movia r8, ADDR_JP1
	stwio r9, 0(r8)
	movia r4, 300000
	call timer
	#stop the motor
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	movia r4, 3500000
	call timer
	br READ_SENSOR_AUTO

#turning on M0 Forward
MOVE_FORWARD_AUTO:		
	movia r9, onF
	movia r8, ADDR_JP1
	stwio r9, 0(r8)

	movia r4, 300000
	call timer	
	#stop the motor
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off

	movia r4, 3000000
	call timer	
	br READ_SENSOR_AUTO
	

#Basic motor moving
MOVE_BACKWARD_AUTO:	
	movia r9, onB
	movia r8, ADDR_JP1
	stwio r9, 0(r8)

	movia r4, 300000
	call timer	
	#stop the motor
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off

	movia r4, 3000000
	call timer	
	br READ_SENSOR_AUTO

STOP_MOTOR_AUTO:
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, 0(r8) #keep all motors sensors off
	br READ_SENSOR_AUTO

#==================== Read Sensor Auto Mode =====================
READ_SENSOR_AUTO:
	#check whether user has pressed begin
	movia r8, HAS_PRESSED_BEGIN
	ldb r8, 0(r8)
	beq r8, r0, MOVE_MOTOR_AUTO
	
	movia r8, ADDR_JP1
	ldwio r9, (r8)
	srli r9, r9, 27
	andi r9, r9, 0x000F

	movia r11, ONE_NOTE_DONE
	ldb r12, 0(r11)
	#if one note not done, Continue read, keep going on black
	beq r12, r0, CHECK_SENSOR_AUTO

	#right now car is on white place, check if there is black place
	andi r10, r9, 0x01
	bne r10, r0, CHECK_SENSOR_AUTO
	andi r10, r9, 0x02
	bne r10, r0, CHECK_SENSOR_AUTO
	andi r10, r9, 0x08
	bne r10, r0, CHECK_SENSOR_AUTO

	br MOVE_MOTOR_AUTO

CHECK_SENSOR_AUTO:
	#set one note done to 0, keep scanning the black place
	movi r12, 0x00
	movia r11, ONE_NOTE_DONE
	stb r12, 0(r11)

	#check three sensors, 0, 1, 3
	andi r10, r9, 0x01
	bne r10, r0, LOAD_INTO_CURRENT_NOTE
	andi r10, r9, 0x02
	bne r10, r0, LOAD_INTO_CURRENT_NOTE
	andi r10, r9, 0x08
	bne r10, r0, LOAD_INTO_CURRENT_NOTE

	#If finish current note reading
	#set one note done to 1, keep going forward on white space
	movi r12, 0x01
	movia r11, ONE_NOTE_DONE
	stb r12, 0(r11)

	movia r11, HAS_REACHED_FIRST_BLACK
	ldb r11, 0(r11)
	bne r11, r0, READ_NOTE_AUTO
	br MOVE_MOTOR_AUTO

UPDATE_AND_CHECK_STATE:
	#reset the current note for next note reading
	movia r11, CURRENT_READING_NOTE
	stw r0, 0(r11)

	#check if complete reading paper
	movui r10, 0x03
	movia r11, READ_NUM_SO_FAR
	ldb r11, 0(r11)
	beq r10, r11, READ_PAPER_DONE
	#add one to read number
	movia r10, READ_NUM_SO_FAR
	addi r11, r11, 0x01
	stb r11, 0(r10)

CHECK_ADD_STATE:
	#check if current note number is over the bar
	movui r10, 0x03
	movia r9, NOTE_NUM
	ldb r9, 0(r9)
	beq r9, r10, add_state_AUTO # if note number == 3
	#if not over, add one note num
	movia r10, NOTE_NUM
	addi r9, r9, 0x01
	stb r9, 0(r10)
	br MOVE_MOTOR_AUTO

READ_PAPER_DONE:
	movia r10, READ_NUM_SO_FAR
	stb r0, 0(r10) #reset read number
	# stop the motor, as the paper is read completely
	movia r10, key_pressed
	movui r9, 's'
	stb r9, 0(r10)
	movia r4, START_X
	call HIGHLIGHT_BLACK
	
	movia r10, HAS_PRESSED_BEGIN
	stb r0, 0(r10)
	br CHECK_ADD_STATE

add_state_AUTO:
	movia r10, NOTE_NUM
	movi r9, 0x00	
	stb r9, 0(r10)	# reset the note number
	movia r10, STATE
	ldb r9, 0(r10)
	addi r9, r9, 1 
	stb r9, 0(r10)  # add one to the state
	br MOVE_MOTOR_AUTO

LOAD_INTO_CURRENT_NOTE:
	#set reach first black to 1, otherwise it will take white as note
	movia r9, HAS_REACHED_FIRST_BLACK
	movui r10, 0x01
	stb r10, 0(r9)

	movia r9, ADDR_JP1
	ldwio r9, (r9)
	srli r9, r9, 27
	andi r9, r9, 0x000F

	#load into global variable current note
	andi r10, r9, 0x01
	bne r10, r0, LOAD_FIRST

CHECK_SECOND:
	andi r10, r9, 0x02
	bne r10, r0, LOAD_SECOND
CHECK_THIRD:
	andi r10, r9, 0x08
	bne r10, r0, LOAD_THIRD
LOAD_CURRENT_NOTE_DONE:
	br MOVE_MOTOR_AUTO

LOAD_FIRST:
	movia r8, ONE
	movui r10, 0x01
	stb r10, 0(r8)
	br CHECK_SECOND	
LOAD_SECOND:
	movia r8, TWO
	movui r10, 0x01
	stb r10, 0(r8)
	br CHECK_THIRD
LOAD_THIRD:
	movia r8, THREE
	movui r10, 0x01
	stb r10, 0(r8)
	br LOAD_CURRENT_NOTE_DONE

READ_NOTE_AUTO:
	#check state
	movia r8, STATE
	ldb r9, 0(r8)

LOAD_BAR_AUTO:
	#depending on the state, load into corresponding bar
	#r8 is the base address of current bar
	muli r9, r9, 0x04
	movia r8, Bar1
	add r8, r8, r9	
	movia r9, NOTE_NUM
	ldb r9, 0(r9)
	add r8, r9, r8
	
LOAD_ONE_NOTE_INTO_BAR_AUTO:
	#r10 as the sensor value
	movia r10, CURRENT_READING_NOTE
	ldw r10, (r10)

	movia r11, 0x00000001
	beq r10, r11, load_do_AUTO
	movia r11, 0x00000100
	beq r10, r11, load_re_AUTO
	movia r11, 0x00010000
	beq r10, r11, load_mi_AUTO
	movia r11, 0x00000101
	beq r10, r11, load_fa_AUTO
	movia r11, 0x00010001
	beq r10, r11, load_so_AUTO
	movia r11, 0x00010100
	beq r10, r11, load_la_AUTO
	movia r11, 0x00010101
	beq r10, r11, load_ti_AUTO
	br UPDATE_AND_CHECK_STATE

load_do_AUTO:
	movui r10, 0x01
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off
	# wait for some time
	#movia r4, 0x0EE6B280
	#call timer

	mov r4, r10
	call PRINT_NOTE

	movui r7, C
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_re_AUTO:
	movui r10, 0x02
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	mov r4, r10
	call PRINT_NOTE

	movui r7, D
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_mi_AUTO:
	movui r10, 0x03
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off
	
	mov r4, r10
	call PRINT_NOTE

	movui r7, E
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_fa_AUTO:
	movui r10, 0x04
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	mov r4, r10
	call PRINT_NOTE

	movui r7, F
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_so_AUTO:
	movui r10, 0x05
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	mov r4, r10
	call PRINT_NOTE

	movui r7, G
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_la_AUTO:
	movui r10, 0x06
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	mov r4, r10
	call PRINT_NOTE

	movui r7, A
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
load_ti_AUTO:
	movui r10, 0x07
	stb r10, 0(r8)

	#stop the motor first
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	mov r4, r10
	call PRINT_NOTE

	movui r7, B
	call Sound

	movia r4, 50000000
	call timer

	br UPDATE_AND_CHECK_STATE
	
	
#============================ FIRST PAGE =============================
TWINKLE:
PUSH_TWINKLE:
	addi sp, sp, -8
    stw r3, 0(sp)
    stw ra, 4(sp)
TWINKLE_LOOP:    
	movia r3, start_boolen
	ldb r3, (r3)
	bne r3, r0, POP_TWINKLE
	call START_NOTICE
	call POLL_START
	call START_ERASE
	call POLL_START
	br TWINKLE_LOOP
POP_TWINKLE:
	ldw ra, 4(sp)
    ldw r3, 0(sp)
    addi sp, sp, 8
    ret
	

#==================== Interrupt Handler ====================
.section .exceptions, "ax"

ISR:
	addi sp, sp, -44
	stw r8, 0(sp)
	stw r9, 4(sp)
    stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)
	stw r13, 20(sp)
    stw r14, 24(sp)
	stw r15, 28(sp)	
	stw r16, 32(sp)
    stw r4, 36(sp)
    stw ra, 40(sp)

	#check irq_PS2
	rdctl et,ipending
        andi et,et,0x0080
	bne et,r0,Serve_PS2

	#check irq_JP1
	rdctl et, ipending
	andi et, et, 0x0800	
	bne et, r0, Serve_JP1

	#check irq_UART
	rdctl et, ipending
	andi et, et, 0x0100
	bne et, r0, Serve_UART

	br exit

Serve_PS2:
	movia r10, KEYBOARD_BUFFER
	
READ_NEXT_INPUT:
	movia et, PS2_KEYBOARD
	ldwio r8, 0(et)
	andi r9, r8, 0x8000
	beq r9, r0, PUT_INTO_BUFFER
	andi r9,r8,0x00ff
    movi et,0x00f0
	beq r9, et, HANDLE_f0
	br HANDLE_DATA
	
HANDLE_f0:
	#if the input is f0
    #skip this char and get the next one
	movia et,PS2_KEYBOARD
    ldwio r8, 0(et)
    andi r9,r8,0x8000
    bne r9,r0,GET_VALID_DATA
    br GET_INVALID_DATA
	
HANDLE_DATA:
	#store the char into the keyboard buffer
    stb r9, 0(r10)
    addi r10, r10, 1
    br READ_NEXT_INPUT
	
GET_VALID_DATA:
	#get the next valid char
   	andi r9,r8,0x0ff
    movi et,0x00f0
    beq r9,et,HANDLE_f0
    br HANDLE_DATA
	
GET_INVALID_DATA:
	#if the next input is not valid
	br READ_NEXT_INPUT
	
	
PUT_INTO_BUFFER:
	#convert user input to ascii
	movia r11, KEYBOARD_BUFFER
LOOP_THROUGH_BUFFER:
	bge r11,r10,PS2_EXIT
    ldb r4,0(r11)
    andi r12,r4,0x00f0
    movi r13,0x00f0
	#if the input buffer is now f0, skip one
    beq r12,r13,INCREMENT
    call CHECK_START

INCREMENT:
	addi r11,r11,1
    br LOOP_THROUGH_BUFFER


CHECK_START:
	#save all callee save registers
    addi sp,sp,-12
    stw r8,0(sp)
	stw r9,4(sp)
    stw ra,8(sp)

    #get the user input
    movia r8, START_ASCII
	ldb r8, 0(r8)
	beq r4, r8, SET_START
	br EXIT_CHECK_START
	
SET_START:
	movia r8, start_boolen
	movi r9, 0x01
	stb r9, 0(r8)
	
	#restore the callee save registers
EXIT_CHECK_START:
    ldw r8,0(sp)
    ldw r9,4(sp)
	ldw ra,8(sp)
    addi sp,sp,12
	ret
	
PS2_EXIT:
	movia r8, start_boolen
	ldb r8, 0(r8)
	bne r8, r0, DISABLE_PS2
	br PS2_TRUE_EXIT
DISABLE_PS2:
	#disable PS2 interrupt
	movia r8, PS2_KEYBOARD  
	stwio r0, 4(r8)
	#disable cpu side of interrupt
	movia r9, 0x00000900	
	wrctl ienable, r9 
PS2_TRUE_EXIT:
	subi ea, ea, 4
    	ldw r8, 0(sp)
    	ldw r9, 4(sp)
    	ldw r10, 8(sp)
	ldw r11, 12(sp)
	ldw r12, 16(sp)
    	ldw r13, 20(sp)
    	ldw r14, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
    ldw r4, 36(sp)
    ldw ra, 40(sp)
    	addi sp, sp, 44
	eret
	
Serve_JP1:
  	movia et, ADDR_JP1_EDGE           # check edge capture register from GPIO JP1
  	ldwio et, 0(et)
  	andhi et, et, 0x8000              # mask bit 31 (sensor 4)  
  	beq et, r0, exit       		  # exit if sensor 4 did not interrupt 

Serve_sensor4:
	movui r8, 's'
	movia et, key_pressed
	stb r8, 0(et)	
	movia r9, ADDR_JP1_EDGE 
	# clear edge captured register
	movia et, 0xFFFFFFFF
	stwio et, 0(r9)
	br exit

Serve_UART:
read_poll:	
	movia r8, JTAG_UART
	ldwio r9, 0(r8)
	andi r10, r9, 0x8000
	beq r10, r0, read_poll
	andi r9, r9, 0x00FF
	movia r8, MANUAL_MODE_ON
	ldb r8, 0(r8)
	beq r8, r0, LOAD_AUTO_KEY
	br LOAD_MANUAL_KEY
#only load necessary keys
LOAD_AUTO_KEY:	
	movui r10, 'd'
	movui r11, 'a'
	movui r12, 's'
	movui r13, 'b'
	movui r14, 'r'
	movui r15, 'm'
	movui r16, 'p'
	beq r9, r10, LOAD_KEY
	beq r9, r11, LOAD_KEY
	beq r9, r12, LOAD_KEY
	beq r9, r13, LOAD_KEY
	beq r9, r14, LOAD_KEY
	beq r9, r15, LOAD_KEY
	beq r9, r16, LOAD_KEY
	br exit
LOAD_MANUAL_KEY:
	movui r10, 'd'
	movui r11, 'a'
	movui r12, 's'
	movui r13, 'r'
	movui r14, 'm'
	movui r15, 'c'
	movui r16, 'p'
	beq r9, r10, LOAD_KEY
	beq r9, r11, LOAD_KEY
	beq r9, r12, LOAD_KEY
	beq r9, r13, LOAD_KEY
	beq r9, r14, LOAD_KEY
	beq r9, r15, LOAD_KEY
	beq r9, r16, LOAD_KEY
	br exit
LOAD_KEY:
	movia et, key_pressed
	stw r9, 0(et)

exit:
		subi ea, ea, 4
    	ldw r8, 0(sp)
    	ldw r9, 4(sp)
    	ldw r10, 8(sp)
	ldw r11, 12(sp)
	ldw r12, 16(sp)
    	ldw r13, 20(sp)
    	ldw r14, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
    ldw r4, 36(sp)
    ldw ra, 40(sp)
    	addi sp, sp, 44
	eret
