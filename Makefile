CC=g++
CFLAGS=-m32 -Wall -pedantic 

ASM=nasm
AFLAGS=-f elf32

all:result

main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp 
func.o: func.asm
	$(ASM) $(AFLAGS) func.asm
result: main.o func.o
	$(CC) $(CFLAGS) main.o func.o -o result
clean: 
	rm *.o

