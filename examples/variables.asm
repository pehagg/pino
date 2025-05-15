;; Example demonstrating variables and data blocks
  
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