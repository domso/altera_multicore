
.section .entry
.global _start
_start:

lui x1, 0x80000

add x2, x0, 0x12
sb x2, 0(x1)

add x2, x0, 0x34
sb x2, 1(x1)

add x2, x0, 0x56
sb x2, 2(x1)

add x2, x0, 0x78
sb x2, 3(x1)

lw x3, 0(x1)

lh x4, 0(x1)
sll x5, x4, 16
lh x4, 2(x1)
add x5, x5, x4
