.equ C, 46
.equ D, 41
.equ E, 36
.equ F, 34
.equ G, 30
.equ A, 27
.equ B, 24
.equ STACK, 0x00400000
.equ SOUND_ADDRESS, 0xff203040
.equ AUDIO_NUM, 0x60000000

.global Poll
Poll:
POLL_PUSH:
    addi sp, sp, -4
    stw r20, 0(sp)
    movia r20, 18000000
Loop:
    addi r20, r20, -1
    bne r20, r0, Loop
POLL_POP:
    ldw r20, 0(sp)
    addi sp, sp, 4
    ret

.global Sound
Sound:
SOUND_PUSH:
	addi sp, sp, -28
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw r19, 12(sp)
    stw r20, 16(sp)
    stw r21, 20(sp)
    stw ra, 24(sp)
SOUND_INIT:
	movui r16, 576
    movia r17, SOUND_ADDRESS	  
    #movi r7, 48				# change this number!
    movia r18, AUDIO_NUM	
    mov r19, r7

SOUND_WRITE_SPACE:
    ldwio r20, 4(r17)
    andhi r21, r20, 0xff00
    beq r21, r0, SOUND_WRITE_SPACE
    andhi r21, r20, 0xff
    beq r21, r0, SOUND_WRITE_SPACE
    
SOUND_TWO_SAMPLES:
    stwio r18, 8(r17)
    stwio r18, 12(r17)
    subi r19, r19, 1
    bne r19, r0, SOUND_WRITE_SPACE
    
SOUND_HALF_INVERT:
    mov r19, r7
    sub r18, r0, r18
    addi r16, r16, -1
    bne r0, r16, SOUND_WRITE_SPACE
SOUND_POP:
    ldw ra, 24(sp)
    ldw r21, 20(sp)
    ldw r20, 16(sp)
    ldw r19, 12(sp)
    ldw r18, 8(sp)
    ldw r17, 4(sp)
	ldw r16, 0(sp)
    addi sp, sp, 28
    ret
