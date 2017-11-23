        .text
        .globl  _start
_start:

        ori     x1, x0, 0x555
	auipc	x1, 0;
        ori     x2, x0, 0x666
        ori     x3, x0, -1
        ori     x4, x0, 0

# 8 taken branches

lab_10:
        blt     x1, x2, lab_20
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x16, x0, -1

lab_20:
        bltu    x1, x2, lab_30
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x17, x0, -1

lab_30:
        blt     x3, x1, lab_40
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x18, x0, -1

lab_40:
        bge     x2, x1, lab_50
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x19, x0, -1

lab_50:
        bgeu    x3, x1, lab_60
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x19, x0, -1

lab_60:
        bge     x1, x3, lab_70
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x20, x0, -1

lab_70:
        bge     x1, x1, lab_80
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x21, x0, -1

lab_80:
        bne     x2, x1, lab_90
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori     x21, x0, -1

# 3 not taken branches

lab_90:
        ori     x22, x0, -1
        ori     x23, x0, -1
        ori     x24, x0, -1
        ori     x25, x0, -1

        bgeu    x1, x3, lab_b0
        addi    x5, x5, 0
        addi    x5, x5, 0
        andi    x22, x22, 0

lab_b0:
        bge     x3, x1, lab_c0
        addi    x5, x5, 0
        addi    x5, x5, 0
        andi    x23, x23, 0

lab_c0:
        blt     x1, x1, lab_d0
        addi    x5, x5, 0
        addi    x5, x5, 0
        andi    x24, x24, 0

lab_d0:
        beq     x2, x1, lab_e0
        addi    x5, x5, 0
        addi    x5, x5, 0
        andi    x25, x25, 0

# jump back

lab_e0:

	auipc	x1, 0;


        bne     x1, x2, lab_10
        addi    x4, x4, 1
        addi    x4, x4, 2
        ori    x26, x0, -1

