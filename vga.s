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
.equ WORD_BOUND, 79

.section .data
.align 2
CURRENT_NOTE: .word 0
CURRENT_STAVE: .word 0
CURRENT_NUM: .word 0
CURRENT_BAR: .word 0
.align 2
SPACE_FOR_CLEAR: .byte ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
.align 2
CLEAR_FIRST_LINE: .byte ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
.align 2
CLEAR_NAME: .byte ' ',' ',' ',' ',' ',' ',' '
.align 2
CLEAR_GUIDE: .byte ' '
.section .text
.global PRINT_NOTE

PRINT_NOTE:
PRINT_NOTE_PUSH:
addi sp, sp, -48
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw r9, 28(sp)
stw r4, 32(sp)
stw r5, 36(sp)
stw r6, 40(sp)
stw ra, 44(sp)
RECOGNIZE_DATA:
movia r16, CURRENT_NOTE
stw r4, (r16)
ldw r16, (r16)
movia r17, CURRENT_STAVE #from 1-4
ldw r17, (r17)
movia r18, CURRENT_NUM #from 1-4
ldw r18, (r18)
movia r19, CURRENT_BAR #from 1-5
ldw r19, (r19)
mov r20, r0
beq r16, r20, RECOGNIZE_DATA #nothing read
addi r20, r20, 1
beq r16, r20, RECOGNIZE_DO
addi r20, r20, 1
beq r16, r20, RECOGNIZE_RUI
addi r20, r20, 1
beq r16, r20, RECOGNIZE_MI
addi r20, r20, 1
beq r16, r20, RECOGNIZE_FA
addi r20, r20, 1
beq r16, r20, RECOGNIZE_SO
addi r20, r20, 1
beq r16, r20, RECOGNIZE_LA
addi r20, r20, 1
beq r16, r20, RECOGNIZE_XI

RECOGNIZE_DO:
movui r20, DO #offset of DO
br CHECK_SLAVE
RECOGNIZE_RUI:
movui r20, RUI #offset of RUI
br CHECK_SLAVE
RECOGNIZE_MI:
movui r20, MI #offset of MI
br CHECK_SLAVE
RECOGNIZE_FA:
movui r20, FA #offset of FA
br CHECK_SLAVE
RECOGNIZE_SO:
movui r20, SO #offset of SO
br CHECK_SLAVE
RECOGNIZE_LA:
movui r20, LA #offset of LA
br CHECK_SLAVE
RECOGNIZE_XI:
movui r20, XI #offset of XI
br CHECK_SLAVE
CHECK_SLAVE:
movui r21, 1
beq r17, r21, GO_FIRST_SLAVE
addi r21, r21, 1
beq r17, r21, GO_SECOND_SLAVE
addi r21, r21, 1
beq r17, r21, GO_THIRD_SLAVE
addi r21, r21, 1
beq r17, r21, GO_FOURTH_SLAVE
GO_FIRST_SLAVE:
movui r21, FIRST_STAVE #the location of first_slave
br CHECK_BAR
GO_SECOND_SLAVE:
movui r21, SECOND_STAVE #the location of first_slave
br CHECK_BAR
GO_THIRD_SLAVE:
movui r21, THIRD_STAVE #the location of first_slave
br CHECK_BAR
GO_FOURTH_SLAVE:
movui r21, FOURTH_STAVE #the location of first_slave
br CHECK_BAR
CHECK_BAR:
movui r8, 1
beq r19, r8, GO_FIRST_BAR
addi r8, r8, 1
beq r19, r8, GO_SECOND_BAR
addi r8, r8, 1
beq r19, r8, GO_THIRD_BAR
addi r8, r8, 1
beq r19, r8, GO_FOURTH_BAR
addi r8, r8, 1
beq r19, r8, GO_FIFTH_BAR
GO_FIRST_BAR:
movui r8, FIRST_BAR #location of the bar
br CHECK_NUM
GO_SECOND_BAR:
movui r8, SECOND_BAR #location of the bar
br CHECK_NUM
GO_THIRD_BAR:
movui r8, THIRD_BAR #location of the bar
br CHECK_NUM
GO_FOURTH_BAR:
movui r8, FOURTH_BAR #location of the bar
br CHECK_NUM
GO_FIFTH_BAR:
movui r8, FIFTH_BAR #location of the bar
br CHECK_NUM
CHECK_NUM:
movui r9, 1
beq r18, r9, GO_FIRST_NUM
addi r9, r9, 1
beq r18, r9, GO_SECOND_NUM
addi r9, r9, 1
beq r18, r9, GO_THIRD_NUM
addi r9, r9, 1
beq r18, r9, GO_FOURTH_NUM
GO_FIRST_NUM:
movui r9, FIRST_IN_BAR
add r4, r8, r9 #x = r8 + r9
add r5, r20, r21 #y = r20 + r21
movui r12, 1
movui r13, 7
beq r16, r12, PRINT_FIRST_DO
beq r16, r13, PRINT_FIRST_XI
call DRAW_UPWARD_NOTE
br FIRST_CONTINUE
PRINT_FIRST_DO:
call DRAW_UPWARD_DO
br FIRST_CONTINUE
PRINT_FIRST_XI:
call DRAW_DOWNWARD_NOTE
FIRST_CONTINUE:
#if bar = 5->slave + 1, bar = 1; if num = 4->bar + 1, num = 1
mov r4, r17 #current stave
mov r5, r18 #current num
mov r6, r19 #current bar
call UPDATE_INFO
br PRINT_NOTE_POP
GO_SECOND_NUM:
movui r9, SECOND_IN_BAR
add r4, r8, r9 #x = r8 + r9
add r5, r20, r21 #y = r20 + r21
movui r12, 1
movui r13, 7
beq r16, r12, PRINT_SECOND_DO
beq r16, r13, PRINT_SECOND_XI
call DRAW_UPWARD_NOTE
br SECOND_CONTINUE
PRINT_SECOND_DO:
call DRAW_UPWARD_DO
br SECOND_CONTINUE
PRINT_SECOND_XI:
call DRAW_DOWNWARD_NOTE
SECOND_CONTINUE:
#if bar = 5->slave + 1, bar = 1; if num = 4->bar + 1, num = 1
mov r4, r17 #current stave
mov r5, r18 #current num
mov r6, r19 #current bar
call UPDATE_INFO
br PRINT_NOTE_POP
GO_THIRD_NUM:
movui r9, THIRD_IN_BAR
add r4, r8, r9 #x = r8 + r9
add r5, r20, r21 #y = r20 + r21
movui r12, 1
movui r13, 7
beq r16, r12, PRINT_THIRD_DO
beq r16, r13, PRINT_THIRD_XI
call DRAW_UPWARD_NOTE
br THIRD_CONTINUE
PRINT_THIRD_DO:
call DRAW_UPWARD_DO
br THIRD_CONTINUE
PRINT_THIRD_XI:
call DRAW_DOWNWARD_NOTE
THIRD_CONTINUE:
#if bar = 5->slave + 1, bar = 1; if num = 4->bar + 1, num = 1
mov r4, r17 #current stave
mov r5, r18 #current num
mov r6, r19 #current bar
call UPDATE_INFO
br PRINT_NOTE_POP
GO_FOURTH_NUM:
movui r9, FOURTH_IN_BAR
add r4, r8, r9 #x = r8 + r9
add r5, r20, r21 #y = r20 + r21
movui r12, 1
movui r13, 7
beq r16, r12, PRINT_FOURTH_DO
beq r16, r13, PRINT_FOURTH_XI
call DRAW_UPWARD_NOTE
br FOURTH_CONTINUE
PRINT_FOURTH_DO:
call DRAW_UPWARD_DO
br FOURTH_CONTINUE
PRINT_FOURTH_XI:
call DRAW_DOWNWARD_NOTE
FOURTH_CONTINUE:
#if bar = 5->slave + 1, bar = 1; if num = 4->bar + 1, num = 1
mov r4, r17 #current stave
mov r5, r18 #current num
mov r6, r19 #current bar
call UPDATE_INFO
br PRINT_NOTE_POP
PRINT_NOTE_POP:
ldw ra, 44(sp)
ldw r6, 40(sp)
ldw r5, 36(sp)
ldw r4, 32(sp)
ldw r9, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 48
ret


.global UPDATE_INFO
UPDATE_INFO: #r4=current stave; r5=current num; r6=current bar
PUSH_UPDATE:
addi sp, sp, -24
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw ra, 20(sp)

movia r16, CURRENT_STAVE
movia r17, CURRENT_NUM
movia r18, CURRENT_BAR
movui r19, 5
movui r20, 4
beq r6, r19, CHECK_NEXT_STAVE
beq r5, r20, NEXT_BAR
addi r5, r5, 1
stw r5, (r17)
br POP_UPDATE
CHECK_NEXT_STAVE:
beq r5, r20, NEXT_STAVE
#current stave, last bar, not last num
addi r5, r5, 1
stw r5, (r17)
br POP_UPDATE
NEXT_STAVE:
beq r4, r20, REACH_MAXIMUM #has reach maximum
addi r4, r4, 1
stw r4, (r16)
movui r5, 1
stw r5, (r17)
movui r6, 1
stw r6, (r18)
br POP_UPDATE
REACH_MAXIMUM:
call WARNING_FULL
br POP_UPDATE
NEXT_BAR:
movui r5, 1
stw r5, (r17)
addi r6, r6, 1
stw r6, (r18)
br POP_UPDATE
POP_UPDATE:
ldw ra, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 24
ret




.global CLEAR_SCREEN
CLEAR_SCREEN:
PUSH:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
INIT:
movia r16, PIXEL
movui r17, 0x0000
movi r18, 0 #current x
movi r19, 0 #current y
movia r20, X_BOUND
movia r21, Y_BOUND
muli r20, r20, 2
muli r21, r21, 1024
DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, DRAW_Y
bgt r19, r21, DRAW_BACK_LINE
br DRAW_X
DRAW_Y:
addi r19, r19, 1024
addi r18, r0, 0
br DRAW_X

DRAW_BACK_LINE:
movi r4, 40
movi r17, 5
movi r18, 1
LOOP_STAVE:
addi sp, sp, -4
stw r4, 0(sp)
call BACKGROUND_LINE
ldw r4, 0(sp)
addi sp, sp, 4
addi r18, r18, 1
addi r4, r4, 5
bgt r18, r17, INIT_SECOND_STAVE
br LOOP_STAVE
INIT_SECOND_STAVE:
addi r4, r4, 18
movi r18, 1
LOOP_SECOND_STAVE:
addi sp, sp, -4
stw r4, 0(sp)
call BACKGROUND_LINE
ldw r4, 0(sp)
addi sp, sp, 4
addi r18, r18, 1
addi r4, r4, 5
bgt r18, r17, INIT_THIRD_STAVE
br LOOP_SECOND_STAVE
INIT_THIRD_STAVE:
addi r4, r4, 18
movi r18, 1
LOOP_THIRD_STAVE:
addi sp, sp, -4
stw r4, 0(sp)
call BACKGROUND_LINE
ldw r4, 0(sp)
addi sp, sp, 4
addi r18, r18, 1
addi r4, r4, 5
bgt r18, r17, INIT_FOURTH_STAVE
br LOOP_THIRD_STAVE
INIT_FOURTH_STAVE:
addi r4, r4, 18
movi r18, 1
LOOP_FOURTH_STAVE:
addi sp, sp, -4
stw r4, 0(sp)
call BACKGROUND_LINE
ldw r4, 0(sp)
addi sp, sp, 4
addi r18, r18, 1
addi r4, r4, 5
bgt r18, r17, DRAW_BUTTON
br LOOP_FOURTH_STAVE

DRAW_BUTTON:
call DRAW_START
call DRAW_PLAY
call DRAW_TITLE
call DRAW_NEW
call DRAW_MANUAL
call DIVIDER
call CLEAR_WARNING
call CLEAR_NULL


CLEAR_DATA:
movui r8, 1
movia r18, CURRENT_NOTE
stw r0, (r18)
movia r18, CURRENT_STAVE
stw r8, (r18)
movia r18, CURRENT_NUM
stw r8, (r18)
movia r18, CURRENT_BAR
stw r8, (r18)
call CLEAR_OPEN_TITLE_FIRST
call CLEAR_OPEN_TITLE_SECOND
call CLEAR_CHAR_GUIDE
call START_ERASE

POP: ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

.global BACKGROUND_LINE
BACKGROUND_LINE:
PUSH_LINE:
addi sp, sp, -16
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r20, 12(sp)
INIT_LINE:
movia r16, PIXEL
movui r17, 0xffff #color
movui r18, 0 #current x
muli r4, r4, 1024
#movia r19, 204800 #current y
movia r20, X_BOUND
muli r20, r20, 2
DRAW_LINE:
add r8, r18, r4
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, POP_LINE
br DRAW_LINE
POP_LINE:
ldw r20, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 16
ret

.global CLEAR_WARNING
CLEAR_WARNING:
CLEAR_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
PRINT_CLEAR:
movia r16, CHARACTER
movia r17, SPACE_FOR_CLEAR
movui r19, 50
movui r20, 50
movui r21, 30 #counter
LOOP_CLEAR:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_CLEAR
CLEAR_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret




.equ START_X, 233
.equ PLAY_X, 279
.equ NEW_X, 185
.equ MANUAL_X, 139
.equ FRAME_LEFT_Y, 218
.section .data
START_BUTTON:
.byte 'S', 'T', 'A', 'R', 'T'
PLAY_BUTTON:
.byte 'P', 'L', 'A', 'Y'
TITLE:
.byte 'M', 'y', ' ', 'S', 'o', 'n', 'g'
NEW_BUTTON:
.byte 'N', 'E', 'W'
MANUAL_BUTTON:
.byte 'M','A','N','U','A','L'
FULL_WARNING:
.byte 'N','o','t','i','c','e',':',' ','R','e','a','c','h',' ','M','a','x','i','m','u','m',' ','8','0',' ','N','o','t','e','s'
NULL_WARNING:
.byte 'O','O','P','S','!',' ','N','o','t','h','i','n','g',' ','d','e','t','e','c','t','e','d','!'
CLEAR_NULL_WARNING:
.byte ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
.section .text

.global DRAW_START
DRAW_START:
PUSH_START:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_START:
movia r16, CHARACTER
movia r17, START_BUTTON
#ldb r18, 0(r17)
movui r19, 60
movui r20, 56
movui r21, 5 #counter
LOOP_START:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_START
START_FRAME:
movui r4, START_X
call FRAME

POP_START:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

.global DRAW_PLAY
DRAW_PLAY:
PUSH_PLAY:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_PLAY:
movia r16, CHARACTER
movia r17, PLAY_BUTTON
#ldb r18, 0(r17)
movui r19, 72
movui r20, 56
movui r21, 4 #counter
LOOP_PLAY:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_PLAY
PLAY_FRAME:
movui r4, PLAY_X
call FRAME
POP_PLAY:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

.global DRAW_NEW
DRAW_NEW:
PUSH_NEW:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_NEW:
movia r16, CHARACTER
movia r17, NEW_BUTTON
#ldb r18, 0(r17)
movui r19, 49
movui r20, 56
movui r21, 3 #counter
LOOP_NEW:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_NEW
NEW_FRAME:
movui r4, NEW_X
call FRAME
POP_NEW:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret


.global DRAW_MANUAL
DRAW_MANUAL:
PUSH_MANUAL:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_MANUAL:
movia r16, CHARACTER
movia r17, MANUAL_BUTTON
#ldb r18, 0(r17)
movui r19, 36
movui r20, 56
movui r21, 6 #counter
LOOP_MANUAL:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_MANUAL
MANUAL_FRAME:
movui r4, MANUAL_X
call FRAME
POP_MANUAL:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret


.global DRAW_TITLE
DRAW_TITLE:
PUSH_TITLE:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
PRINT_TITLE:
movia r16, CHARACTER
movia r17, TITLE
#ldb r18, 0(r17)
movui r19, 35
movui r20, 5
movui r21, 7 #counter
LOOP_TITLE:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_TITLE

POP_TITLE:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

.global WARNING_FULL
WARNING_FULL:
FULL_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
PRINT_FULL:
movia r16, CHARACTER
movia r17, FULL_WARNING
#ldb r18, 0(r17)
movui r19, 50
movui r20, 50
movui r21, 30 #counter
LOOP_FULL:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_FULL
FULL_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret


.global WARNING_NULL
WARNING_NULL:
NULL_PUSH:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_NULL:
movia r16, CHARACTER
movia r17, NULL_WARNING
#ldb r18, 0(r17)
movui r19, 29
movui r20, 50
movui r21, 23 #counter
LOOP_NULL:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_NULL
call HIGHLIGHT_NULL
NULL_POP:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

HIGHLIGHT_NULL: #import r4=x_location(data set in .equ section)
PUSH_HN:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
HN_INIT:
movia r16, PIXEL
movui r17, 0xf800
movui r18, 110 #current x
movui r19, 198 #current y
addi r18, r18, 1
addi r19, r19, 1
movui r20, 100 #x counter
movui r21, 7 #y counter
muli r20, r20, 2
muli r21, r21, 1024
muli r18, r18, 2
muli r19, r19, 1024
add r20, r20, r18
add r21, r21, r19
HN_DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, HN_DRAW_Y
bgt r19, r21, HN_ERASE_EXTRA
br HN_DRAW_X
HN_DRAW_Y:
addi r19, r19, 1024
movui r18, 110
addi r18, r18, 1
muli r18, r18, 2
br HN_DRAW_X
HN_ERASE_EXTRA:
addi r18, r18, -2
add r8, r18, r19
add r8, r8, r16
movui r17, 0x0000
sthio r17, (r8)
HN_POP:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret


.global CLEAR_NULL
CLEAR_NULL:
addi sp, sp, -4
stw ra, 0(sp)
call CLEAR_HN_BACKGROUND
call CLEAR_HN_CHARACTER
ldw ra, 0(sp)
addi sp, sp, 4
ret

CLEAR_HN_BACKGROUND:
PUSH_CHN:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
CHN_INIT:
movia r16, PIXEL
movui r17, 0x0000
movui r18, 110 #current x
movui r19, 198 #current y
addi r18, r18, 1
addi r19, r19, 1
movui r20, 100 #x counter
movui r21, 7 #y counter
muli r20, r20, 2
muli r21, r21, 1024
muli r18, r18, 2
muli r19, r19, 1024
add r20, r20, r18
add r21, r21, r19
CHN_DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, CHN_DRAW_Y
bgt r19, r21, CHN_ERASE_EXTRA
br CHN_DRAW_X
CHN_DRAW_Y:
addi r19, r19, 1024
movui r18, 110
addi r18, r18, 1
muli r18, r18, 2
br CHN_DRAW_X
CHN_ERASE_EXTRA:
addi r18, r18, -2
add r8, r18, r19
add r8, r8, r16
movui r17, 0x0000
sthio r17, (r8)
CHN_POP:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

CLEAR_HN_CHARACTER:
CLEAR_NULL_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
CLEAR_PRINT_NULL:
movia r16, CHARACTER
movia r17, CLEAR_NULL_WARNING
#ldb r18, 0(r17)
movui r19, 29
movui r20, 50
movui r21, 23 #counter
CLEAR_LOOP_NULL:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, CLEAR_LOOP_NULL
CLEAR_NULL_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

.global FRAME
FRAME:
PUSH_FRAME:
addi sp, sp, -20
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
INIT_FRAME:
movia r16, PIXEL
movui r17, 0xffff #color
movui r18, FRAME_LEFT_Y #current y
muli r18, r18, 1024 #current y (in 1024 base)
muli r4, r4, 2 #current x (in 2 base)
movui r20, 32
DRAW_FRAME_TOP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r4, r4, 2
addi r20, r20, -1
ble r20, r0, FRAME_RIGHT_INIT
br DRAW_FRAME_TOP
FRAME_RIGHT_INIT:
movui r20, 15
RIGHT_LOOP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r18, r18, 1024
addi r20, r20, -1
ble r20, r0, FRAME_BOTTOM_INIT
br RIGHT_LOOP
FRAME_BOTTOM_INIT:
movui r20, 32
BOTTOM_LOOP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r4, r4, -2
addi r20, r20, -1
ble r20, r0, FRAME_LEFT_INIT
br BOTTOM_LOOP
FRAME_LEFT_INIT:
movui r20, 15
LEFT_LOOP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r18, r18, -1024
addi r20, r20, -1
ble r20, r0, POP_FRAME
br LEFT_LOOP
POP_FRAME:
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 20
ret

.global HIGHLIGHT_RED
HIGHLIGHT_RED: #import r4=x_location(data set in .equ section)
PUSH_RED:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
RED_INIT:
movia r16, PIXEL
movui r17, 0xf800
mov r18, r4 #current x
movui r19, FRAME_LEFT_Y #current y
addi r18, r18, 1
addi r19, r19, 1
movui r20, 30 #x counter
movui r21, 13 #y counter
muli r20, r20, 2
muli r21, r21, 1024
muli r18, r18, 2
muli r19, r19, 1024
add r20, r20, r18
add r21, r21, r19
RED_DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, RED_DRAW_Y
bgt r19, r21, ERASE_EXTRA
br RED_DRAW_X
RED_DRAW_Y:
addi r19, r19, 1024
mov r18, r4
addi r18, r18, 1
muli r18, r18, 2
br RED_DRAW_X
ERASE_EXTRA:
addi r18, r18, -2
add r8, r18, r19
add r8, r8, r16
movui r17, 0xffff
sthio r17, (r8)
RED_POP:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

.global HIGHLIGHT_BLACK
HIGHLIGHT_BLACK: #import r4=x_location(data set in .equ section)
PUSH_BLACK:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
BLACK_INIT:
movia r16, PIXEL
movui r17, 0x00
mov r18, r4 #current x
movui r19, FRAME_LEFT_Y #current y
addi r18, r18, 1
addi r19, r19, 1
movui r20, 30 #x counter
movui r21, 13 #y counter
muli r20, r20, 2
muli r21, r21, 1024
muli r18, r18, 2
muli r19, r19, 1024
add r20, r20, r18
add r21, r21, r19
BLACK_DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, BLACK_DRAW_Y
bgt r19, r21, ERASE_EXTRA_BLACK
br BLACK_DRAW_X
BLACK_DRAW_Y:
addi r19, r19, 1024
mov r18, r4
addi r18, r18, 1
muli r18, r18, 2
br BLACK_DRAW_X
ERASE_EXTRA_BLACK:
addi r18, r18, -2
add r8, r18, r19
add r8, r8, r16
movui r17, 0xffff
sthio r17, (r8)
BLACK_POP:
ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret


.global DRAW_UPWARD_NOTE
DRAW_UPWARD_NOTE:
PUSH_NOTE:
addi sp, sp, -24
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r8, 20(sp)
INIT_NOTE:#r4=body_x r5=body_y
movia r16, PIXEL
movui r17, 0xffff #color
mov r18, r4 #current x
muli r18, r18, 2 #current x (in 2 base)
mov r19, r5
muli r19, r19, 1024 #current Y (in 1024 base)
movui r20, 3
DRAW_NOTE_TOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, SECOND_LINE_INIT
br DRAW_NOTE_TOP
SECOND_LINE_INIT:
movui r20, 4
addi r19, r19, 1024
addi r18, r18, -2
SECOND_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, THIRD_LINE_INIT
br SECOND_LINE_LOOP
THIRD_LINE_INIT:
movui r20, 4
addi r19, r19, 1024
addi r18, r18, 2
THIRD_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, FOURTH_LINE_INIT
br THIRD_LINE_LOOP
FOURTH_LINE_INIT:
movui r20, 3
addi r19, r19, 1024
addi r18, r18, -2
FOURTH_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, VERTICAL
br FOURTH_LINE_LOOP
VERTICAL:
movui r20, 12
addi r19, r19, -1024
addi r18, r18, 8
VERTICAL_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r19, r19, -1024
addi r20, r20, -1
ble r20, r0, POP_NOTE
br VERTICAL_LOOP
POP_NOTE:
ldw r8, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 24
ret

.global DRAW_UPWARD_DO
DRAW_UPWARD_DO:
PUSH_DO:
addi sp, sp, -24
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r8, 20(sp)
INIT_DO:#r4=body_x r5=body_y
movia r16, PIXEL
movui r17, 0xffff #color
mov r18, r4 #current x
muli r18, r18, 2 #current x (in 2 base)
mov r19, r5
muli r19, r19, 1024 #current Y (in 1024 base)
movui r20, 3
DRAW_DO_TOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, SECOND_DO_INIT
br DRAW_DO_TOP
SECOND_DO_INIT:
movui r20, 4
addi r19, r19, 1024
addi r18, r18, -2
SECOND_DO_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, THIRD_DO_INIT
br SECOND_DO_LOOP
THIRD_DO_INIT:
movui r20, 8
addi r19, r19, 1024
addi r18, r18, -2
THIRD_DO_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, FOURTH_DO_INIT
br THIRD_DO_LOOP
FOURTH_DO_INIT:
movui r20, 3
addi r19, r19, 1024
addi r18, r18, -6
FOURTH_DO_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, DO_VERTICAL
br FOURTH_DO_LOOP
DO_VERTICAL:
movui r20, 12
addi r19, r19, -1024
addi r18, r18, 8
DO_VERTICAL_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r19, r19, -1024
addi r20, r20, -1
ble r20, r0, POP_DO
br DO_VERTICAL_LOOP
POP_DO:
ldw r8, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 24
ret

.global DRAW_DOWNWARD_NOTE
DRAW_DOWNWARD_NOTE:
PUSH_DOWN_NOTE:
addi sp, sp, -24
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r8, 20(sp)
INIT_DOWN_NOTE:#r4=body_x r5=body_y
movia r16, PIXEL
movui r17, 0xffff #color
mov r18, r4 #current x
muli r18, r18, 2 #current x (in 2 base)
mov r19, r5
muli r19, r19, 1024 #current Y (in 1024 base)
movui r20, 3
DOWN_DRAW_NOTE_TOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, DOWN_SECOND_LINE_INIT
br DOWN_DRAW_NOTE_TOP
DOWN_SECOND_LINE_INIT:
movui r20, 4
addi r19, r19, 1024
addi r18, r18, 0
DOWN_SECOND_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, DOWN_THIRD_LINE_INIT
br DOWN_SECOND_LINE_LOOP
DOWN_THIRD_LINE_INIT:
movui r20, 4
addi r19, r19, 1024
addi r18, r18, 2
DOWN_THIRD_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, 2
addi r20, r20, -1
ble r20, r0, DOWN_FOURTH_LINE_INIT
br DOWN_THIRD_LINE_LOOP
DOWN_FOURTH_LINE_INIT:
movui r20, 3
addi r19, r19, 1024
addi r18, r18, -4
DOWN_FOURTH_LINE_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r18, r18, -2
addi r20, r20, -1
ble r20, r0, DOWN_VERTICAL
br DOWN_FOURTH_LINE_LOOP
DOWN_VERTICAL:
mov r18, r4
mov r19, r5
muli r18, r18, 2
muli r19, r19, 1024
addi r19, r19, 1024
addi r18, r18, -2
movui r20, 12
DOWN_VERTICAL_LOOP:
add r8, r18, r19
add r8, r8, r16
sthio r17, (r8)
addi r19, r19, 1024
addi r20, r20, -1
ble r20, r0, DOWN_POP_NOTE
br DOWN_VERTICAL_LOOP
DOWN_POP_NOTE:
ldw r8, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 24
ret


.global DIVIDER
DIVIDER:
DIVIDER_PUSH:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw r9, 28(sp)
DIVIDER_INIT:
movia r16, PIXEL
movui r17, 0xffff
movui r18, 64 #current x
movui r19, 40  #current y
movui r20, 5
muli r18, r18, 2
muli r19, r19, 1024
movui r8, 20
movui r9, X_BOUND
muli r9, r9, 2
br FIRST_SINGLE
FIRST_DIVIDER:
movui r8, 20
addi r18, r18, 128
movui r19, 40
muli r19, r19, 1024
bge r18, r9, FIRST_LAST_SINGLE
FIRST_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, FIRST_SINGLE
br FIRST_DIVIDER
FIRST_LAST_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, FIRST_LAST_SINGLE
SECOND_DIVIDER_INIT:
movui r18, 64 #current x
movui r19, 84  #current y
movui r20, 5
muli r18, r18, 2
muli r19, r19, 1024
movui r8, 20
movui r9, X_BOUND
muli r9, r9, 2
br SECOND_SINGLE
SECOND_DIVIDER:
movui r8, 20
addi r18, r18, 128
movui r19, 84
muli r19, r19, 1024
bge r18, r9, SECOND_LAST_SINGLE
SECOND_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, SECOND_SINGLE
br SECOND_DIVIDER
SECOND_LAST_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, SECOND_LAST_SINGLE
THIRD_DIVIDER_INIT:
movui r18, 64 #current x
movui r19, 127  #current y
movui r20, 5
muli r18, r18, 2
muli r19, r19, 1024
movui r8, 20
movui r9, X_BOUND
muli r9, r9, 2
br THIRD_SINGLE
THIRD_DIVIDER:
movui r8, 20
addi r18, r18, 128
movui r19, 127
muli r19, r19, 1024
bge r18, r9, THIRD_LAST_SINGLE
THIRD_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, THIRD_SINGLE
br THIRD_DIVIDER
THIRD_LAST_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, THIRD_LAST_SINGLE
FOURTH_DIVIDER_INIT:
movui r18, 64 #current x
movui r19, 170  #current y
movui r20, 5
muli r18, r18, 2
muli r19, r19, 1024
movui r8, 20
movui r9, X_BOUND
muli r9, r9, 2
br FOURTH_SINGLE
FOURTH_DIVIDER:
movui r8, 20
addi r18, r18, 128
movui r19, 170
muli r19, r19, 1024
bge r18, r9, FOURTH_LAST_SINGLE
FOURTH_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, FOURTH_SINGLE
br FOURTH_DIVIDER
FOURTH_LAST_SINGLE:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, FOURTH_LAST_SINGLE

DIVIDER_POP:
ldw r9, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret

# start_erase is in another file

CLEAR_OPEN_TITLE_FIRST:
CLEAR_OPEN_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
CLEAR_PRINT_OPEN:
movia r16, CHARACTER
movia r17, CLEAR_FIRST_LINE
#ldb r18, 0(r17)
movui r19, 28
movui r20, 27
movui r21, 20 #counter
CLEAR_LOOP_OPEN:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, CLEAR_LOOP_OPEN
CLEAR_OPEN_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

CLEAR_OPEN_TITLE_SECOND:
CLEAR_PUSH_OT:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
CLEAR_PRINT_OT:
movia r16, CHARACTER
movia r17, CLEAR_NAME
#ldb r18, 0(r17)
movui r19, 35
movui r20, 29
movui r21, 7 #counter
CLEAR_LOOP_OT:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, CLEAR_LOOP_OT

CLEAR_POP_OT:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

CLEAR_CHAR_GUIDE:
CLEAR_GUIDE_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
CLEAR_GUIDE_INIT:
movia r16, CHARACTER
movia r17, CLEAR_GUIDE
movui r19, 0
movui r20, 10
ldb r18, 0(r17) #load the space
movia r21, WORD_BOUND #counter
CLEAR_GUIDE_LOOP:
muli r8, r20, 128 # Y * 128
add r8, r19, r8 #formula = X + Y * 128
add r8, r8, r16 #address + offset
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, CLEAR_GUIDE_LOOP

CLEAR_GUIDE_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret
