#!/bin/sh
# Assemble, link and convert a RISC-V assembler file to a VHDL ROM

if [ "$1" = "" ]
then
    echo "Usage: $0 <filename>"
    echo "Assemble, link and convert a RISC-V assembler file to a VHDL ROM"
    exit
fi

FILENAME=`basename -s .S $1`
HERE=`dirname $0`

riscv64-unknown-elf-as $1 -o $FILENAME.o
riscv64-unknown-elf-ld -Ttext 0 --entry=0 $FILENAME.o -o $FILENAME.elf
$HERE/riscv-elf2altera.x -r $FILENAME.elf 4 1024 > $FILENAME.vhd

#rm $FILENAME.o $FILENAME.elf
