        .text
        .globl  main
        .org 0
main:
        or      x1, x0, 0x555
        xor     x2, x2, x2
        xor     x3, x3, x3

lab1:
        jalr    x5, x0, 0x00000028      # lab2
        addi    x2, x2, 1
        addi    x2, x2, 2
        addi    x2, x2, 4
        addi    x2, x2, 8
        ori     x3, x3, -1
        ori     x16, x16, -1

lab2:   li      x4, 0x00000040          # lab3-8
        jalr    x6, x4, 8
        addi    x2, x2, 0x10
        addi    x2, x2, 0x20
        addi    x2, x2, 0x40
        addi    x2, x2, 0x80
        ori     x3, x3, -1
        ori     x17, x17, -1

lab3:   addi    x9, x6, 0x0068-0x0030   # lab4-(lab2+8)
        jalr    x7, x9, 0
        addi    x2, x2, 0x10
        addi    x2, x2, 0x20
        addi    x2, x2, 0x40
        addi    x2, x2, 0x80
        ori     x3, x3, -1
        ori     x17, x17, -1


lab4:   jalr    x8, x0, 0x0000000c   # lab1
        addi    x2, x2, 0x100
        addi    x2, x2, 0x200
        addi    x2, x2, 0x400
        addi    x2, x2, -0x800
        ori     x3, x3, -1
        ori     x18, x18, -1

