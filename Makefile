all: flow

flow: main.c
	gcc -o flow main.c -no-pie

clean: all
	rm *.o flow