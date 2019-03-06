.equ PIXEL,0x08000000
.equ CHARACTER,0x09000000
.equ X_BOUND,319
.equ Y_BOUND,239
.equ STACK,0x00400000
.equ GUIDE_BLOCK_Y, 5
.equ GUIDE_DO, 5
.equ GUIDE_RUI, 50
.equ GUIDE_MI, 95
.equ GUIDE_FA, 140
.equ GUIDE_SO, 185
.equ GUIDE_LA, 230
.equ GUIDE_XI, 275
.section .data
.align 2
GUIDE_DO_CHAR: .byte 'D','O'
.align 2
GUIDE_RUI_CHAR: .byte 'R','U','I'
.align 2
GUIDE_MI_CHAR: .byte 'M','I'
.align 2
GUIDE_FA_CHAR: .byte 'F','A'
.align 2
GUIDE_SO_CHAR: .byte 'S','O'
.align 2
GUIDE_LA_CHAR: .byte 'L','A'
.align 2
GUIDE_XI_CHAR: .byte 'X','I'
.align 2
OPENNING_FIRST_LINE: .byte 'E','C','E','2','4','3',' ','F','I','N','A','L',' ','P','R','O','J','E','C','T'
.align 2
OPENNING_NAME: .byte 'M','Y',' ','S','O','N','G'
.align 2
NOTICE_START: .byte 'S','T','A','R','T'
EARASE_START: .byte ' ',' ',' ',' ',' '

.section .text

.global FIRST_PAGE
FIRST_PAGE:
PUSH_FP:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
INIT_FP:
movia r16, PIXEL
movui r17, 0x0000
movi r18, 0 #current x
movi r19, 0 #current y
movia r20, X_BOUND
movia r21, Y_BOUND
muli r20, r20, 2
muli r21, r21, 1024
DRAW_X_FP:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, DRAW_Y_FP
bgt r19, r21, DRAW_GUIDE
br DRAW_X_FP
DRAW_Y_FP:
addi r19, r19, 1024
addi r18, r0, 0
br DRAW_X_FP

DRAW_GUIDE:
DRAW_GUIDE_DO:
movui r4, GUIDE_DO
call FRAME_FP
movui r4, GUIDE_DO
call GUIDE_DIVIDER_FP
movui r4, GUIDE_DO
addi r4, r4, 23
call FILL_GUIDE

DRAW_GUIDE_RUI:
movui r4, GUIDE_RUI
call FRAME_FP
movui r4, GUIDE_RUI
call GUIDE_DIVIDER_FP
movui r4, GUIDE_RUI
addi r4, r4, 11
call FILL_GUIDE

DRAW_GUIDE_MI:
movui r4, GUIDE_MI
call FRAME_FP
movui r4, GUIDE_MI
call GUIDE_DIVIDER_FP
movui r4, GUIDE_MI
call FILL_GUIDE

DRAW_GUIDE_FA:
movui r4, GUIDE_FA
call FRAME_FP
movui r4, GUIDE_FA
call GUIDE_DIVIDER_FP
movui r4, GUIDE_FA
addi r4, r4, 11
call FILL_GUIDE
movui r4, GUIDE_FA
addi r4, r4, 23
call FILL_GUIDE

DRAW_GUIDE_SO:
movui r4, GUIDE_SO
call FRAME_FP
movui r4, GUIDE_SO
call GUIDE_DIVIDER_FP
movui r4, GUIDE_SO
call FILL_GUIDE
movui r4, GUIDE_SO
addi r4, r4, 23
call FILL_GUIDE

DRAW_GUIDE_LA:
movui r4, GUIDE_LA
call FRAME_FP
movui r4, GUIDE_LA
call GUIDE_DIVIDER_FP
movui r4, GUIDE_LA
call FILL_GUIDE
movui r4, GUIDE_LA
addi r4, r4, 11
call FILL_GUIDE

DRAW_GUIDE_XI:
movui r4, GUIDE_XI
call FRAME_FP
movui r4, GUIDE_XI
call GUIDE_DIVIDER_FP
movui r4, GUIDE_XI
call FILL_GUIDE
movui r4, GUIDE_XI
addi r4, r4, 11
call FILL_GUIDE
movui r4, GUIDE_XI
addi r4, r4, 23
call FILL_GUIDE

DRAW_CHAR_GUIDE:
call CHARACTER_GUIDE

START_TITLE:
call OPEN_TITLE_FIRST
call OPEN_TITLE_SECOND

POP_FP: ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret


FRAME_FP:
PUSH_FRAME_FP:
addi sp, sp, -20
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
INIT_FRAME_FP:
movia r16, PIXEL
movui r17, 0xffff #color
movui r18, GUIDE_BLOCK_Y #current y
muli r18, r18, 1024 #current y (in 1024 base)
muli r4, r4, 2 #current x (in 2 base)
movui r20, 35
DRAW_FRAME_TOP_FP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r4, r4, 2
addi r20, r20, -1
ble r20, r0, FRAME_RIGHT_INIT_FP
br DRAW_FRAME_TOP_FP
FRAME_RIGHT_INIT_FP:
movui r20, 20
RIGHT_LOOP_FP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r18, r18, 1024
addi r20, r20, -1
ble r20, r0, FRAME_BOTTOM_INIT_FP
br RIGHT_LOOP_FP
FRAME_BOTTOM_INIT_FP:
movui r20, 35
BOTTOM_LOOP_FP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r4, r4, -2
addi r20, r20, -1
ble r20, r0, FRAME_LEFT_INIT_FP
br BOTTOM_LOOP_FP
FRAME_LEFT_INIT_FP:
movui r20, 20
LEFT_LOOP_FP:
add r19, r18, r4
add r19, r19, r16
sthio r17, (r19)
addi r18, r18, -1024
addi r20, r20, -1
ble r20, r0, POP_FRAME_FP
br LEFT_LOOP_FP
POP_FRAME_FP:
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 20
ret


GUIDE_DIVIDER_FP:
DIVIDER_PUSH_FP:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw r9, 28(sp)
DIVIDER_INIT_FP:
movia r16, PIXEL
movui r17, 0xffff
addi r18, r4, 11 #current x
movui r19, GUIDE_BLOCK_Y  #current y
movui r20, 2
muli r18, r18, 2
muli r19, r19, 1024
movui r8, 20
br FIRST_SINGLE_FP
FIRST_SINGLE_FP:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, FIRST_SINGLE_FP
SECOND_SINGLE_INIT_FP:
movui r8, 20
addi r18, r18, 24
movui r19, GUIDE_BLOCK_Y
muli r19, r19, 1024
SECOND_SINGLE_FP:
add r21, r18, r19
add r21, r21, r16
sthio r17, (r21)
addi r19, r19, 1024
addi r8, r8, -1
bgt r8, r0, SECOND_SINGLE_FP
DIVIDER_POP_FP:
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

FILL_GUIDE: #import r4=x_location(data set in .equ section)
PUSH_FG:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
FG_INIT:
movia r16, PIXEL
movui r17, 0xffff
mov r18, r4 #current x
movui r19, GUIDE_BLOCK_Y #current y
addi r18, r18, 1
addi r19, r19, 1
movui r20, 10 #x counter
movui r21, 18 #y counter
muli r20, r20, 2
muli r21, r21, 1024
muli r18, r18, 2
muli r19, r19, 1024
add r20, r20, r18
add r21, r21, r19
FG_DRAW_X:
add r8, r18, r19
add r8, r8, r16 #current location
sthio r17, (r8)
addi r18, r18, 2
bgt r18, r20, FG_DRAW_Y
bgt r19, r21, ERASE_EXTRA_FG
br FG_DRAW_X
FG_DRAW_Y:
addi r19, r19, 1024
mov r18, r4
addi r18, r18, 1
muli r18, r18, 2
br FG_DRAW_X
ERASE_EXTRA_FG:
addi r18, r18, -2
add r8, r18, r19
add r8, r8, r16
movui r17, 0xffff
sthio r17, (r8)
FG_POP:
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

CHARACTER_GUIDE: 
CG_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)

GUIDE_DO_INIT:
movia r16, CHARACTER
movia r17, GUIDE_DO_CHAR
movui r19, 5
movui r20, 10
movui r21, 2 #counter
GUIDE_DO_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_DO_LOOP

GUIDE_RUI_INIT:
movia r16, CHARACTER
movia r17, GUIDE_RUI_CHAR
movui r19, 16
movui r20, 10
movui r21, 2 #counter
GUIDE_RUI_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_RUI_LOOP

GUIDE_MI_INIT:
movia r16, CHARACTER
movia r17, GUIDE_MI_CHAR
movui r19, 27
movui r20, 10
movui r21, 2 #counter
GUIDE_MI_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_MI_LOOP

GUIDE_FA_INIT:
movia r16, CHARACTER
movia r17, GUIDE_FA_CHAR
movui r19, 38
movui r20, 10
movui r21, 2 #counter
GUIDE_FA_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_FA_LOOP

GUIDE_SO_INIT:
movia r16, CHARACTER
movia r17, GUIDE_SO_CHAR
movui r19, 50
movui r20, 10
movui r21, 2 #counter
GUIDE_SO_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_SO_LOOP

GUIDE_LA_INIT:
movia r16, CHARACTER
movia r17, GUIDE_LA_CHAR
movui r19, 61
movui r20, 10
movui r21, 2 #counter
GUIDE_LA_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_LA_LOOP

GUIDE_XI_INIT:
movia r16, CHARACTER
movia r17, GUIDE_XI_CHAR
movui r19, 72
movui r20, 10
movui r21, 2 #counter
GUIDE_XI_LOOP:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, GUIDE_XI_LOOP

CG_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

OPEN_TITLE_FIRST:
OPEN_PUSH:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
PRINT_OPEN:
movia r16, CHARACTER
movia r17, OPENNING_FIRST_LINE
#ldb r18, 0(r17)
movui r19, 28
movui r20, 27
movui r21, 20 #counter
LOOP_OPEN:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_OPEN
OPEN_POP:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

OPEN_TITLE_SECOND:
PUSH_OT:
addi sp, sp, -28
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
PRINT_OT:
movia r16, CHARACTER
movia r17, OPENNING_NAME
#ldb r18, 0(r17)
movui r19, 35
movui r20, 29
movui r21, 7 #counter
LOOP_OT:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_OT

POP_OT:
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 28
ret

.global START_NOTICE
START_NOTICE:
PUSH_SN:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_SN:
movia r16, CHARACTER
movia r17, NOTICE_START
movui r19, 36
movui r20, 40
movui r21, 5 #counter
LOOP_SN:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_SN
POP_SN:
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

.global START_ERASE
START_ERASE:
PUSH_START_ERASE:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
PRINT_START_ERASE:
movia r16, CHARACTER
movia r17, EARASE_START
#ldb r18, 0(r17)
movui r19, 36
movui r20, 40
movui r21, 5 #counter
LOOP_START_ERASE:
ldb r18, 0(r17)
addi r17, r17, 1
muli r8, r20, 128
add r8, r19, r8
add r8, r8, r16
stbio r18, 0(r8)
addi r19, r19, 1
addi r21, r21, -1
bgt r21, r0, LOOP_START_ERASE
POP_START_ERASE:
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

.global POLL_START

POLL_START:
POLL_PUSH_START:
	addi sp, sp, -4
    stw r20, 0(sp)
	movia r20, 25000000
Loop_START:
    addi r20, r20, -1
    bne r20, r0, Loop_START
POLL_POP_START:
    ldw r20, 0(sp)
    addi sp, sp, 4
    ret
    