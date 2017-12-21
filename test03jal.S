        .text
        .globl  _start
_start:
        or      x1, x0, 0x555
        xor     x2, x2, x2
        xor     x3, x3, x3

lab1:
	lui	sp, 0x300
	sw	x0, -8(sp)
        jal     x5, lab2
        addi    x2, x2, 1
        addi    x2, x2, 2
        addi    x2, x2, 4
        addi    x2, x2, 8
        ori     x3, x3, -1
        ori     x16, x16, -1

lab2:   li      x4, 0x00000040          # lab3-8
        jal     x6, lab3
        addi    x2, x2, 0x10
        addi    x2, x2, 0x20
        addi    x2, x2, 0x40
        addi    x2, x2, 0x80
        ori     x3, x3, -1
        ori     x17, x17, -1

lab3:   addi    x5, x1, 0x0068-0x0030   # lab4-(lab2+8)
        jal     x7, lab4
        addi    x2, x2, 0x10
        addi    x2, x2, 0x20
        addi    x2, x2, 0x40
        addi    x2, x2, 0x80
        ori     x3, x3, -1
        ori     x17, x17, -1


lab4:   jal     x8, lab1
        addi    x2, x2, 0x100
        addi    x2, x2, 0x200
        addi    x2, x2, 0x400
        addi    x2, x2, -0x800
        ori     x3, x3, -1
        ori     x18, x18, -1

