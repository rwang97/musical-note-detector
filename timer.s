.equ TIMER, 0xFF202000

.global timer


timer: 
	movia r8, TIMER
       
	ldwio r12, 8(r8)
		
	andi r9, r4, 0x0000FFFF
        
	stwio r9, 12(r8)
        
	srli r4, r4, 16
        
	mov r9, r4
        
	stwio r9, 12(r8)
        
	stwio r0, (r8)
        
	movi r9, 0b0100
        
	stwio r9, 4(r8)


Wait_Poll:   ldwio r9, (r8)
	  
	andi r9, r9, 0x00000001
      
	beq r9, zero, Wait_Poll
      
	ret
