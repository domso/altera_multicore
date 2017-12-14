        .text
        .globl  _start
_start:
       li x3, 0x200000
       li x4, 0x200004
       li x5, 0x200008
       li x6, 0x20000c

	addi x8, zero, 0x100
	addi x9, zero, 0x200
	addi x10, zero, 0x300
	addi x11, zero, 0x400

	
loop:

	sw x8, 0(x3) #0x100
	sw x9, 0(x4) #0x200
	sw x10, 0(x5) #0x300
	sw x11, 0(x6) #0x400

	lw x11, 0(x3) #0x100
	lw x10, 0(x4) #0x200
	lw x9, 0(x5) #0x300
	lw x8, 0(x6)  #0x400

	sw x9, 0(x3) #0x400
	lw x9, 0(x5) #0x300
	sw x9, 0(x6) #0x300
	lw x9, 0(x4) #0x200
	sw x9, 0(x5) #0x200

        j       loop
