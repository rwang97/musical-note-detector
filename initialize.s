.equ stack, 0x00400000
.equ JTAG_UART, 0xFF201000
.equ ADDR_JP1, 0xFF200060
.equ PS2_KEYBOARD, 0xff200100
.equ off, 0xFFFFFFFF

.section .text
.global initialize

initialize:
#================= enable motors & sensors ====================

	#init all motor s and sensors
	movia r8, ADDR_JP1 #pointer to base of PIT
	movia r9, off
	stwio r9, (r8) #keep all motors sensors off

	#init all motors to output
	#init all sensors 1. on/off as output, 2. ready as input
	movia r9, 0x07F557FF #magic number
	stwio r9, 4(r8)

#==================== enable interrupts =======================

	# load sensor4 threshold value f and enable sensor4
   	movia  r9,  0xffbbffff       # set motors off enable threshold load sensor 4
   	stwio  r9,  0(r8)            # store value into threshold register

	# disable threshold register and enable state mode
   	movia  r9,  0xffdfffff      # keep threshold value same in case update occurs before state mode is enabled
   	stwio  r9,  0(r8)

	# load sensor0 threshold value b and enable sensor0
   	movia  r9,  0xfdbffbff       # set motors off enable threshold load sensor 0
   	stwio  r9,  0(r8)            # store value into threshold register

	# disable threshold register and enable state mode
   	movia  r9,  0xfddfffff      # keep threshold value same in case update occurs before state mode is enabled
   	stwio  r9,  0(r8)

	# load sensor1 threshold value b and enable sensor1
   	movia  r9,  0xfdbfefff       # set motors off enable threshold load sensor 1
   	stwio  r9,  0(r8)            # store value into threshold register

	# disable threshold register and enable state mode
   	movia  r9,  0xfddfffff      # keep threshold value same in case update occurs before state mode is enabled
   	stwio  r9,  0(r8)

	# load sensor3 threshold value b and enable sensor3
   	movia  r9,  0xfdbeffff       # set motors off enable threshold load sensor 3
   	stwio  r9,  0(r8)            # store value into threshold register

	# disable threshold register and enable state mode
   	movia  r9,  0xfddfffff      # keep threshold value same in case update occurs before state mode is enabled
   	stwio  r9,  0(r8)

	# enable interrupts, JP1 & UART

	# init JP1 device interrupt
    	movia  r9, 0x80000000       # enable interrupts on sensor 4
    	stwio  r9, 8(r8)

	#init UART device interrupt
	movia r8, JTAG_UART   
	movui r9, 0x01
	stwio r9, 4(r8)

	#init PS2 interrupt
	movia r8, PS2_KEYBOARD  
	movui r9, 0x01
	stwio r9, 4(r8)
	
	#enable cpu side of interrupt
	movia r9, 0x00800980		# both JP1 & UART & PS2
	wrctl ienable, r9 

	#enable PIE
    	movi r9, 0x01
	wrctl status, r9

	ret
