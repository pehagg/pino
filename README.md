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

### Milestone: 0.3.0 "Debugger"

- [ ] epic: debugger support [emulator]

### Milestone: 0.2.0 "Strings"

- [ ] epic: support for strings [vm] [compiler]

### Milestone: 0.1.0 "Unconference Edition"

- [ ] feat: support for for data blocks and variables [compiler]
- [ ] feat: support for drawing sprites [vm] [emulator]
- [ ] refactor: proper literal handling [scanner]
- [ ] refactor: use proper allocators [compiler] [emulator]
- [ ] chore: clean up code using Karl's book as guidance [compiler] [emulator]
- [ ] refactor: rename LIT to PSH [compiler]
- [ ] feat: proper compiler errors [compiler]
- [x] fix: decimal parsing
- [x] feat: support for drawing basic shapes [vm] [emulator]
- [x] feat: support for comments [compiler]
- [x] feat: support for text output [vm]
- [x] feat: compile program file (assy) into binary (rom) [compiler]
- [x] feat: run rom file [emulator]

## Memory Map

### Console

#### FF00 CHROUT

Print a character to standard output.

(c --)

c = ascii code for character to print

#### BGNDRW Begin drawing (0xFF10)

Begin drawing procedures. Must be called before drawing. End drawing with ENDDRW.

#### ENDDRW End drawing (0xFF11)

End drawing procedures.

#### PIXOUT Draw a pixel to the screen (0xFF12)

Draw a pixel to the screen using the specified color.

(x y color --)

x = x coordinate
y = y coordinate
color = color from palette

#### LINOUT Draw line (0xFF13)

Draw a line to the screen using specified color.

(x1 y1 x2 y2 color --)

x1 = starting x coordinate
y1 = starting y coordinate
x2 = ending x coordinate
y2 = ending y coordinate
color = color from palette

#### TXTOUT Draw character to screen (0xFF14)

Draw a character with predefined font to the screen.

(char x y color --)

char = ascii code for character being drawn
x = x coordinate
y = y coordinate
color = color from palette

#### PALETTE (0xFF20 - 0xFF84)

Color palette of 16 colors, in rgba format. The color codes themselves are not used, instead you use the index relative to the base address of 0xFF20.
