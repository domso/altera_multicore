        .text
        .globl  _start
_start:
        ori     x1, x0, 0x100
        ori     x2, x0, 0x200
        ori     x3, x0, -1
        ori     x4, x0, 0x018

loop:

# Aufgabe 10/1:
# Durch wren_b=1 werden 4 Schreibzugriffe mit folgenden Werten angezeigt:_
#                                 address_b data_b

	beq	x0, x0, test
        sw      x3, 0x200(x1)   # 0x80      0x100
        sw      x4, 0x204(x1)   # 0x81      0x200
test:
        sw      x1, 0x200(x0)   # 0x80      0x100
        sw      x2, 0x204(x0)   # 0x81      0x200
        sw      x3, 0x108(x1)   # 0x82      0xffffffff
        sw      x4, 0x00c(x2)   # 0x83      0x18


        lw      x5, 0x200(x0)
        lw      x6, 0x204(x0)
        lw      x7, 0x108(x1)
        lw      x8, 0x00c(x2)

        mv      x9, x8
        mv      x10, x8
        mv      x11, x8
        mv      x12, x8

        sw      x5, 0x1f8(x8)
        sw      x6, 0x214(x0)
        sw      x7, 0x118(x1)
        sw      x8, 0x01c(x2)

        ori     x13, x0, 0x12
        ori     x14, x0, 0x34
        ori     x15, x0, 0x56
        ori     x16, x0, 0x78



	sw	x0, 0x220(x0)


        sb      x13, 0x223(x0)
	nop
	lw	x17, 0x220(x0)

        sb      x14, 0x222(x0)
	nop
	lw	x17, 0x220(x0)

        sb      x15, 0x121(x1)
	nop
	lw	x17, 0x220(x0)

	sb      x16, 0x020(x2)
	nop
        lw      x17, 0x220(x0)      # 0x12345678

        mv      x18, x17
        mv      x18, x17

        lui     x19, 0x98765
        addi    x19, x19, 0x432
        sw      x19, 0x224(x0)      # 0x98765432
        lui     x20, 0xfedcb
        addi    x20, x20, 0x298
        sw      x20, 0x228(x0)      # 0xfedcb298

        sh      x19, 0x22c(x0)
        sh      x20, 0x22e(x0)
        lw      x21, 0x22c(x0)      # 0xb2985432

        lb      x22, 0x225(x0)      # 0x00000054
        lb      x22, 0x227(x0)      # 0xffffff98
        lbu     x22, 0x226(x0)      # 0x00000076
        lbu     x22, 0x22a(x0)      # 0x000000dc

        lh      x22, 0x224(x0)      # 0x00005432
        lh      x22, 0x228(x0)      # 0xffffb298
        lhu     x22, 0x224(x0)      # 0x00005432
        lhu     x22, 0x22a(x0)      # 0x0000fedc

        j       loop
