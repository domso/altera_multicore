/* Test programm to print a decimal counter on the 7-segment display */



/* Startup code: do not alter! */
asm(
    ".section \".entry\"\n\t"
    ".global _start\n\t"
    "_start:\n\t"

 "lui x1, 0x80000\n\t"

"add x2, x0, 0x12\n\t"
"sb x2, 0(x1)\n\t"

"add x2, x0, 0x34\n\t"
"sb x2, 1(x1)\n\t"

"add x2, x0, 0x56\n\t"
"sb x2, 2(x1)\n\t"

"add x2, x0, 0x78\n\t"
"sb x2, 3(x1)\n\t"

"lw x3, 0(x1)\n\t"

"lh x4, 0(x1)\n\t"
"sll x5, x4, 16\n\t"
"lh x4, 2(x1)\n\t"
"add x5, x5, x4\n\t"


   "j _start\n\t"
    "lui sp, 0x300\n\t"
    "jal main\n\t"
    ".global _exit\n\t"
    "_exit:\n\t"
    "j _exit\n\t"
);



#define write_csr(reg, val) asm volatile ("csrw " #reg ", %0" :: "r"(val))


static const char digit[16] = {
 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,
 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71,
}; 

void print_int_7(int v)
{
	write_csr(0x788, ~(
        (digit[(v/1000) % 10] << 24) |
        (digit[(v/100) % 10] << 16) |
        (digit[(v/10) % 10] << 8) |
        digit[v % 10]));
}

int main()
{
    int i=0;
    while (1) {
        print_int_7(i / 7000);
	i++;
    }
}
