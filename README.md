# ASMSSE
Vectorized CPU operations in example project implemented in NASM x64

## Structure

Repository consists of:
* `flow.asm` - file with defintion of two global functions (`start` and `step`) and one helper function (`apply_col`)
* `main.c` - file consists of a program which tests `start` and `step`
 functions
* `Makefile`
* `tests` - directory with few tests in txt format

## Dependencies
* gcc
* nasm

## Usage
```bash
make
./flow tests/small.txt
```
Run parameter should contain path to appropriate test file with initial description of matrix with floating-point type numbers and list of input columns.
Testing program loads file, initializes the game by calling `start` function 
and afterwards calls `step` in the loop and prints the content of the matrix to stdout.