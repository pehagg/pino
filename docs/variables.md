# Data Blocks and Variables in Pino

This document explains how to use data blocks and variables in the Pino assembly language.

## Defining Variables

Variables are defined using the `VAR` directive, followed by a name and an optional size (in bytes). If no size is specified, the default is 1 byte.

```assembly
VAR counter 1    ; Define a 1-byte variable named 'counter'
VAR numbers 10   ; Define a 10-byte array named 'numbers'
VAR result 1     ; Define a 1-byte variable for the result
```

## Initializing Data

Data can be initialized using the `DATA` directive, followed by a variable name and one or more values.

```assembly
DATA counter 0   ; Initialize counter to 0
DATA numbers 1 2 3 4 5 6 7 8 9 10  ; Initialize the array with values 1-10
```

## Using Variables in Code

Variables can be referenced by name in instructions that take memory addresses:

```assembly
ldz counter    ; Load the value of 'counter' into the stack
stz counter    ; Store the top value of the stack into 'counter'
lda numbers    ; Load the value at the address 'numbers'
sta numbers    ; Store the top value of the stack at the address 'numbers'
```

## Memory Organization

- Code starts at address 0x0100
- Data section starts at address 0x0200
- Variables are allocated sequentially in the data section

## Example

Here's a complete example that sums the numbers in an array:

```assembly
;; Define variables
VAR counter 1    ; Define a 1-byte variable named 'counter'
VAR numbers 10   ; Define a 10-byte array named 'numbers'
VAR result 1     ; Define a 1-byte variable for the result

;; Initialize data
DATA counter 0   ; Initialize counter to 0
DATA numbers 1 2 3 4 5 6 7 8 9 10  ; Initialize the array with values 1-10

;; Sum the numbers in the array
  psh $0         ; Initialize sum to 0
  ldz counter    ; Load counter value
loop:
  dup            ; Duplicate counter for comparison
  cmp $a         ; Compare with 10 (array size)
  beq done       ; If equal, we're done
  
  dup            ; Duplicate counter for array indexing
  add numbers    ; Add base address of 'numbers' array to get the address of the current element
  lda $0         ; Load the value at that address (high byte is 0)
  add            ; Add to our running sum
  
  ldz counter    ; Load counter again
  inc            ; Increment counter
  stz counter    ; Store updated counter
  
  jmp loop       ; Repeat
  
done:
  pop            ; Remove counter from stack
  stz result     ; Store the sum in 'result'
  brk            ; End program
```

This program calculates the sum of the numbers 1 through 10 and stores the result in the `result` variable.