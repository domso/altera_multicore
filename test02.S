        .text
        .globl  _start
_start:

	add	x1, x0, -1

	add	x2, x0, 0x55
	sll	x3, x2, 8

	add	x2, x3, 0x55
	sll	x3, x2, 8

	add	x2, x3, 0x55	
	sll	x3, x2, 8

	add	x2, x3, 0x55	


	xor	x3, x2, x1	
	add	x1, x3, 0x0056
