.phony: run clean

default: run

day02.o: day02.asm
	nasm -g -f elf64 -o day02.o day02.asm

day02: day02.o
	gcc -o day02 day02.o -l c

run: day02
	./day02

clean:
	rm day02.o day02