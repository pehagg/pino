# Pino

A tiny stack-based virtual machine.

## Bytecode

The lowest level of programming Pino is on the bytecode level. For this we have a simple assembler like language, inspired by 6502 assembly. Here's an example of computing the first 14 digits of the Fibonacci sequence.

```
  lit $0    ; (-- 0)
  lit $1    ; (0 -- 0 1)
loop:
  ovr       ; (0 1 -- 0 1 0)
  ovr       ; (0 1 0 -- 0 1 0 1)
  add       ; (0 1 0 1 -- 0 1 1)
  cmp $e9   ; are we at 233?
  bne loop  ; nope, go back
  brk       ;
```

## Tasks

- [x] feat: compile program file (assy) into binary (rom)
- [ ] feat: run rom file
