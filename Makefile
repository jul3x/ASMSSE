all: flow

flow: main.c flow.o
	gcc -o flow main.c flow.o -no-pie

flow.o: flow.asm
	nasm -f elf64 -F dwarf -g flow.asm

clean: all
	rm *.o flow