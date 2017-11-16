        .text
        .globl  _start
_start:
        or      x15, x0, 0x555
        or      x16, x0, 0x2aa
        or      x17, x0, x16

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x16, x16, x15   # 0x7ff
        add     x17, x15, x17   # 0x7ff

        or      x6, x0, 0x400
        or      x5, x0, 0x100
        or      x4, x0, 0x040
        or      x3, x0, 0x010
        or      x2, x0, 0x004
        or      x1, x0, 0x001
        add     x18, x1, x2     # 0x005

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x19, x2, x1     # 0x00a

        or      x6, x0, 0x400
        or      x5, x0, 0x100
        or      x4, x0, 0x040
        or      x3, x0, 0x010
        or      x2, x0, 0x004
        or      x1, x0, 0x001
        add     x20, x2, x3     # 0x014

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x21, x3, x2     # 0x028

        or      x6, x0, 0x400
        or      x5, x0, 0x100
        or      x4, x0, 0x040
        or      x3, x0, 0x010
        or      x2, x0, 0x004
        or      x1, x0, 0x001
        add     x22, x3, x4     # 0x050

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x23, x4, x3     # 0x0a0

        or      x6, x0, 0x400
        or      x5, x0, 0x100
        or      x4, x0, 0x040
        or      x3, x0, 0x010
        or      x2, x0, 0x004
        or      x1, x0, 0x001
        add     x24, x4, x5     # 0x140

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x25, x5, x4     # 0x280

        or      x6, x0, 0x400
        or      x5, x0, 0x100
        or      x4, x0, 0x040
        or      x3, x0, 0x010
        or      x2, x0, 0x004
        or      x1, x0, 0x001
        add     x26, x5, x6     # 0x500

        or      x6, x0, -0x800
        or      x5, x0, 0x200
        or      x4, x0, 0x080
        or      x3, x0, 0x020
        or      x2, x0, 0x008
        or      x1, x0, 0x002
        add     x27, x6, x5     # 0xfffffa00




	lui	x5, 0xabcde;
	add	x5, x5, 0x89;
