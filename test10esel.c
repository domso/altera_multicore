/* Test programm to print "ESEL" on the 7-segment display */



/* Startup code: do not alter! */
asm(
    ".section\".entry\"\n\t"
    ".global _start\n\t"
    "_start:\n\t"
    "lui sp, 1\n\t"
    "jal main\n\t"
    ".global _exit\n\t"
    "_exit:\n\t"
    "j _exit\n\t"
);


#define write_csr(reg, val) asm volatile ("csrw " #reg ", %0" :: "r"(val))


int main()
{
    write_csr(0x788, 0x869286C7);
}