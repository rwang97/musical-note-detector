.equ CHARACTER,0x09000000
.equ CHAR_X_BOUND,79
.equ CHAR_Y_BOUND,59
.section .data
ERASE_ALL_CHAR: .byte ' '

.section .text
.global CLEAR_CHAR
CLEAR_CHAR:
PUSH_CC:
addi sp, sp, -32
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r8, 24(sp)
stw ra, 28(sp)
INIT_CC:
movia r16, CHARACTER
movia r17, ERASE_ALL_CHAR
ldb r17, (r17) #r17 = space
movi r18, 0 #current x
movi r19, 0 #current y
movia r20, CHAR_X_BOUND
movia r21, CHAR_Y_BOUND
#muli r20, r20, 2
muli r21, r21, 128
CLEAR_X_CC:
add r8, r18, r19
add r8, r8, r16 #current location
stbio r17, (r8)
addi r18, r18, 1
bgt r18, r20, CLEAR_Y_CC
bgt r19, r21, POP_CC
br CLEAR_X_CC
CLEAR_Y_CC:
addi r19, r19, 128
addi r18, r0, 0
br CLEAR_X_CC
POP_CC: ldw ra, 28(sp)
ldw r8, 24(sp)
ldw r21, 20(sp)
ldw r20, 16(sp)
ldw r19, 12(sp)
ldw r18, 8(sp)
ldw r17, 4(sp)
ldw r16, 0(sp)
addi sp, sp, 32
ret
