;; compute first Fibonacci sequence
  pshb $0
  pshb $1
loop:
  ovr        ; (0 1 -- 0 1 0)
  ovr        ; (0 1 0 -- 0 1 0 1)
  add        ; (0 1 0 1 -- 0 1 1)
  dup        ; dup value, cmp consumes it
  pshq $68a3dd8e61eccfbd ; push comparison value (92nd fibinacci number that still fits into a cell of 64 bits)
  cmp        ; compare top two values (pops both)
  bne loop   ; nope, loop
  brk

