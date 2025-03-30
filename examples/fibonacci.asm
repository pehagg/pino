;; compute the first 14 numbers in the Fibonacci sequence
  lit $0
  lit 1
loop:
  ovr       ; (0 1 -- 0 1 0)
  ovr       ; (0 1 0 -- 0 1 0 1)
  add       ; (0 1 0 1 -- 0 1 1)
  cmp $e9   ; are we done yet?
  bne loop  ; nope, loop
  brk

