        .text
        .globl  _start
_start:

        add     x2, x1, x1
        sll     x8, x2, x2
        or      x10, x8, x2
        slt     x30, x8, x10
        sltu    x31, x10, x8
        or      x3, x1, x2
        sll     x16, x3, x10
        and     x17, x10, x3

