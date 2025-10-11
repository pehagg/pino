package vm

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

// Core data types
Cell :: distinct u64 // Primary stack type (qword)
Word :: distinct u16 // 2-byte operations
DWord :: distinct u32 // 4-byte operations
Address :: distinct u16 // Memory addressing

// Multi-width push operations
OP_PSHB :: 0x01 // Push byte (1 byte literal → Cell)
OP_PSHW :: 0x02 // Push word (2 byte literal → Cell)
OP_PSHD :: 0x03 // Push dword (4 byte literal → Cell)  
OP_PSHQ :: 0x04 // Push qword (8 byte literal → Cell)

// Stack operations
OP_POP :: 0x10 // Drop top-most item from stack
OP_DUP :: 0x11 // Duplicate top-most item in stack
OP_SWP :: 0x12 // Swap two top-most items
OP_OVR :: 0x13 // Push second to top-most item to top
OP_ROT :: 0x14 // Rotate three top-most items left
OP_NIP :: 0x15 // Drop second item in stack
OP_TCK :: 0x16 // Push top-most item to third place

// Multi-width load operations
OP_LDB :: 0x20 // Load byte from address → Cell
OP_LDW :: 0x21 // Load word from address → Cell
OP_LDD :: 0x22 // Load dword from address → Cell
OP_LDQ :: 0x23 // Load qword from address → Cell

// Multi-width store operations
OP_STB :: 0x30 // Store Cell as byte to address
OP_STW :: 0x31 // Store Cell as word to address
OP_STD :: 0x32 // Store Cell as dword to address
OP_STQ :: 0x33 // Store Cell as qword to address

// Arithmetic operations (Cell-width)
OP_ADD :: 0x40 // Add two Cells
OP_SUB :: 0x41 // Subtract two Cells
OP_MUL :: 0x42 // Multiply two Cells
OP_DIV :: 0x43 // Divide two Cells
OP_INC :: 0x44 // Increment Cell
OP_DEC :: 0x45 // Decrement Cell

// Control flow
OP_JMP :: 0x50 // Jump to address explicitly
OP_JSR :: 0x51 // Jump to subroutine
OP_RTS :: 0x52 // Return from subroutine
OP_CMP :: 0x53 // Compare Cell with literal, set flags
OP_BEQ :: 0x54 // Branch if equal (Z flag set)
OP_BNE :: 0x55 // Branch if not equal (Z flag clear)

// System
OP_BRK :: 0x00 // Break
OP_HCF :: 0xff // Halt execution, i.e. panic

ADDR_CHROUT :: 0xff00
ADDR_BGNDRW :: 0xff10
ADDR_ENDDRW :: 0xff11
ADDR_PIXOUT :: 0xff12
ADDR_LINOUT :: 0xff13
ADDR_TXTOUT :: 0xff14
ADDR_PALETTE :: 0xff20

StatusFlag :: enum {
	N, // Negative
	V, // Overflow
	Z, // Zero
	C, // Carry
}

StatusRegister :: bit_set[StatusFlag;u8]

VirtualMachine :: struct {
	wst:      [256]Cell, // Cell-based stack
	sp:       u8,
	rst:      [256]Address,
	rp:       u8,
	mem:      [65536]u8, // Byte-addressable memory
	pc:       Address,
	status:   StatusRegister,
	headless: bool,
	font:     rl.Font,
}

/*
Push Cell onto work stack.

Increments stack pointer (sp), wraps in case of an overflow.

Inputs:
- vm: A pointer to VirtualMachine.
- value: A Cell value.
*/
push :: proc(vm: ^VirtualMachine, value: Cell) {
	vm.wst[vm.sp] = value
	vm.sp += 1
}

/*
Pop Cell off work stack.

Decrements stack pointer (sp), wraps in case of underflow.

Inputs:
- vm: A pointer to a VirtualMachine. 

Returns:
- value: A Cell value.
*/
pop :: proc(vm: ^VirtualMachine) -> Cell {
	vm.sp -= 1
	return vm.wst[vm.sp]
}

/*
Peek top-most Cell value.

Does not mutate stack pointer (sp).

Inputs:
- vm: A reference to a VirtualMachine

Returns:
- value: Cell value of top-most item on stack.
*/
peek :: proc(vm: VirtualMachine) -> Cell {
	return vm.wst[vm.sp - 1]
}

/*
Return depth of stack (value of sp).

Inputs:
- vm: A reference to a VirtualMachine.

Returns:
- depth: Depth of stack
*/
depth :: proc(vm: VirtualMachine) -> u8 {
	return vm.sp
}

/*
Read value from memory.

Inputs:
- vm: A reference to a VirtualMachine.
- address: Address to read from

Returns:
- value: Byte at given address.
*/
read :: proc(vm: VirtualMachine, address: Address) -> u8 {
	return vm.mem[address]
}

/*
Read word (2 bytes) from memory.

Inputs:
- vm: A reference to a VirtualMachine.
- address: Address to read from

Returns:
- word at given address.
*/
read_word :: proc(vm: VirtualMachine, address: Address) -> Word {
	hi := Word(read(vm, address + 0)) << 8
	lo := Word(read(vm, address + 1))
	return hi | lo
}

/*
Read dword (4 bytes) from memory.

Inputs:
- vm: A reference to a VirtualMachine.
- address: Address to read from

Returns:
- dword at given address.
*/
read_dword :: proc(vm: VirtualMachine, address: Address) -> DWord {
	a := DWord(read(vm, address + 0)) << 24
	b := DWord(read(vm, address + 1)) << 16
	c := DWord(read(vm, address + 2)) << 8
	d := DWord(read(vm, address + 3))
	return a | b | c | d
}

/*
Read qword (8 bytes) from memory.

Inputs:
- vm: A reference to a VirtualMachine.
- address: Address to read from

Returns:
- qword (Cell) at given address.
*/
read_qword :: proc(vm: VirtualMachine, address: Address) -> Cell {
	value := Cell(0)
	for i in 0 ..< 8 {
		byte_val := read(vm, address + Address(i))
		value |= Cell(byte_val) << Cell(8 * (7 - i))
	}
	return value
}

/*
Write a byte to address.

Inputs:
- vm: A pointer to a VirtualMachine.
- address: Address to write to.
- value: value to write.
*/
write :: proc(vm: ^VirtualMachine, address: Address, value: u8) {
	vm.mem[address] = value
}

/*
Write word (2 bytes) to address.

Inputs:
- vm: A pointer to a VirtualMachine.
- address: Address to write to.
- value: word value to write.
*/
write_word :: proc(vm: ^VirtualMachine, address: Address, value: Word) {
	write(vm, address + 0, u8(value >> 8))
	write(vm, address + 1, u8(value))
}

/*
Write dword (4 bytes) to address.

Inputs:
- vm: A pointer to a VirtualMachine.
- address: Address to write to.
- value: dword value to write.
*/
write_dword :: proc(vm: ^VirtualMachine, address: Address, value: DWord) {
	write(vm, address + 0, u8(value >> 24))
	write(vm, address + 1, u8(value >> 16))
	write(vm, address + 2, u8(value >> 8))
	write(vm, address + 3, u8(value))
}

/*
Write qword (8 bytes) to address.

Inputs:
- vm: A pointer to a VirtualMachine.
- address: Address to write to.
- value: qword (Cell) value to write.
*/
write_qword :: proc(vm: ^VirtualMachine, address: Address, value: Cell) {
	for i in 0 ..< 8 {
		write(vm, address + Address(i), u8(value >> Cell(8 * (7 - i))))
	}
}

/*
Convert Cell to cstring (uses low 8 bits as character).

Inputs:
- cell: Cell to convert.

Returns:
- cstring: A cstring.
*/
to_cstring :: proc(cell: Cell) -> (cstring, mem.Allocator_Error) {
	char := u8(cell) // Use low 8 bits
	sb: strings.Builder
	defer strings.builder_destroy(&sb)
	strings.write_rune(&sb, rune(char))
	return strings.to_cstring(&sb)
}

/*
Call a kernel function.

Inputs:
- vn: A pointer to a VirtualMachine.
- address: Start address of kernel function.

Returns:
- success: true if the call was successful
*/
call :: proc(vm: ^VirtualMachine, address: Address) -> bool {
	switch address {
	case ADDR_CHROUT:
		char := pop(vm)
		fmt.print(rune(u8(char))) // Use low 8 bits for character
	case ADDR_BGNDRW:
		if vm.headless do return false
		rl.BeginDrawing()
	case ADDR_ENDDRW:
		if vm.headless do return false
		rl.EndDrawing()
	case ADDR_PIXOUT:
		if vm.headless do return false
		palette_index := pop(vm)
		y := pop(vm)
		x := pop(vm)
		rl.DrawPixel(i32(x), i32(y), color(vm^, u8(palette_index)))
	case ADDR_LINOUT:
		if vm.headless do return false
		palette_index := pop(vm)
		end_y := pop(vm)
		end_x := pop(vm)
		start_y := pop(vm)
		start_x := pop(vm)
		rl.DrawLine(
			i32(start_x),
			i32(start_y),
			i32(end_x),
			i32(end_y),
			color(vm^, u8(palette_index)),
		)
	case ADDR_TXTOUT:
		if vm.headless do return false
		palette_index := pop(vm)
		y := pop(vm)
		x := pop(vm)
		char := pop(vm)

		cstr, err := to_cstring(char)
		if err != .None {
			return false
		}

		position := rl.Vector2{f32(x), f32(y)}
		color := color(vm^, u8(palette_index))
		rl.DrawTextEx(vm.font, cstr, position, 20, 0, color)
	case:
		log.warn("invalid call to address:", address)
		return false
	}

	return true
}

/*
Fetch next instruction/operation.

The procedure increments the program counter (pc).

Inputs:
- vm: A pointer to a VirtualMachine.

Returns:
- op: next operation
*/
fetch :: proc(vm: ^VirtualMachine) -> u8 {
	op := vm.mem[vm.pc]
	vm.pc += 1
	return op
}

/*
Update status flags.

Updates the status register based on top-most Cell value in stack.

Inputs:
- vm: A pointer to a VirtualMachine.
*/
update_status_flags :: proc(vm: ^VirtualMachine) {
	value := peek(vm^)

	// Negative if MSB of 64-bit value is set
	if Cell(value) & Cell(0x8000_0000_0000_0000) != 0 {
		vm.status += {.N}
	} else {
		vm.status -= {.N}
	}

	if value == Cell(0) {
		vm.status += {.Z}
	} else {
		vm.status -= {.Z}
	}
}

/*
Look up color from palette.

Inputs:
- vm: a reference to a VirtualMachine.
- index: palette index.

Returns:
- color: Color from palette.
*/
color :: proc(vm: VirtualMachine, index: u8) -> rl.Color {
	address := ADDR_PALETTE + Address(index * 4)
	value := read_dword(vm, address)
	return rl.GetColor(u32(value))
}

/*
Perform hard reset.

This procedure resets the vm to it's startup state.

Inputs:
- vmL A ponter to a VirtualMachine
*/
reset :: proc(vm: ^VirtualMachine) {
	// reset pointers
	vm.sp = 0
	vm.pc = 0x0100
	vm.rp = 0

	// initialize standard palette
	write_dword(vm, ADDR_PALETTE + 0, 0x000000ff) // Black
	write_dword(vm, ADDR_PALETTE + 4, 0xffffffff) // White
	write_dword(vm, ADDR_PALETTE + 8, 0x00ffffff) // Cyan
	write_dword(vm, ADDR_PALETTE + 12, 0x880000ff) // Red
	write_dword(vm, ADDR_PALETTE + 16, 0x8a1789ff) // Purple
	write_dword(vm, ADDR_PALETTE + 20, 0x2020ffff) // Blue
	write_dword(vm, ADDR_PALETTE + 24, 0xffec00ff) // Yellow
	write_dword(vm, ADDR_PALETTE + 28, 0xe06000ff) // Orange
	write_dword(vm, ADDR_PALETTE + 32, 0x604000ff) // Brown
	write_dword(vm, ADDR_PALETTE + 36, 0xff4040ff) // Light Red
	write_dword(vm, ADDR_PALETTE + 40, 0x404040ff) // Dark Gray
	write_dword(vm, ADDR_PALETTE + 44, 0x808080ff) // Medium Gray
	write_dword(vm, ADDR_PALETTE + 48, 0x60ff60ff) // Light Green
	write_dword(vm, ADDR_PALETTE + 52, 0x409effff) // Light Blue
	write_dword(vm, ADDR_PALETTE + 56, 0xc0c0c0ff) // Light Gray
	write_dword(vm, ADDR_PALETTE + 60, 0x009000ff) // Green
	write_dword(vm, ADDR_PALETTE + 64, 0xff00ffff) // Magenta
	write_dword(vm, ADDR_PALETTE + 68, 0xffbb80ff) // Peach
	write_dword(vm, ADDR_PALETTE + 72, 0x0047abff) // Cobalt
	write_dword(vm, ADDR_PALETTE + 76, 0xab4642ff) // Brick Red
	write_dword(vm, ADDR_PALETTE + 80, 0x242461ff) // Navy
	write_dword(vm, ADDR_PALETTE + 84, 0x008080ff) // Teal
	write_dword(vm, ADDR_PALETTE + 88, 0x80ff00ff) // Lime
	write_dword(vm, ADDR_PALETTE + 92, 0x800000ff) // Maroon
	write_dword(vm, ADDR_PALETTE + 96, 0x808000ff) // Olive
	write_dword(vm, ADDR_PALETTE + 100, 0xbc9cffff) // Lavender
	write_dword(vm, ADDR_PALETTE + 104, 0xff80c0ff) // Pink
	write_dword(vm, ADDR_PALETTE + 108, 0xffbf00ff) // Amber
	write_dword(vm, ADDR_PALETTE + 112, 0x87ceebff) // Sky Blue
	write_dword(vm, ADDR_PALETTE + 116, 0x228b22ff) // Forest Green
	write_dword(vm, ADDR_PALETTE + 120, 0x4b0082ff) // Indigo
	write_dword(vm, ADDR_PALETTE + 124, 0x4682b4ff) // Steel Blue
}

/*
Evaluate bytecode.

Inputs:
- vm: Pointer to VirtualMachine.
- headless: run vm in headless mode, defaults to true.

Returns:
- success: true if evluation was successful.
*/
evaluate :: proc(vm: ^VirtualMachine, code: []u8, headless: bool = true) -> bool {
	vm.headless = headless

	reset(vm)

	// copy bytecode to memory at 0x0100 (page 2)
	for i in 0 ..< len(code) {
		vm.mem[0x0100 + i] = code[i]
	}

	// main loop
	for {
		if !vm.headless && rl.WindowShouldClose() {
			return true
		}

		op := fetch(vm)
		switch op {
		case OP_BRK:
			return true

		// Multi-width push operations
		case OP_PSHB:
			literal := fetch(vm) // 1 byte
			push(vm, Cell(literal)) // Zero-extend to Cell

		case OP_PSHW:
			hi := fetch(vm) // High byte
			lo := fetch(vm) // Low byte
			value := Word(hi) << 8 | Word(lo)
			push(vm, Cell(value)) // Zero-extend to Cell

		case OP_PSHD:
			// Read 4 bytes and combine
			value := DWord(0)
			for i in 0 ..< 4 {
				byte_val := fetch(vm)
				value |= DWord(byte_val) << DWord(8 * (3 - i))
			}
			push(vm, Cell(value))

		case OP_PSHQ:
			// Read 8 bytes and combine  
			value := Cell(0)
			for i in 0 ..< 8 {
				byte_val := fetch(vm)
				value |= Cell(byte_val) << Cell(8 * (7 - i))
			}
			push(vm, value)

		// Stack operations
		case OP_POP:
			pop(vm)
		case OP_DUP:
			value := pop(vm)
			push(vm, value)
			push(vm, value)
		case OP_SWP:
			b := pop(vm)
			a := pop(vm)
			push(vm, b)
			push(vm, a)
		case OP_OVR:
			b := pop(vm)
			a := pop(vm)
			push(vm, a)
			push(vm, b)
			push(vm, a)
		case OP_ROT:
			c := pop(vm)
			b := pop(vm)
			a := pop(vm)
			push(vm, c)
			push(vm, a)
			push(vm, b)
		case OP_NIP:
			b := pop(vm)
			a := pop(vm)
			push(vm, b)
		case OP_TCK:
			b := pop(vm)
			a := pop(vm)
			push(vm, b)
			push(vm, a)
			push(vm, b)

		// Multi-width load operations
		case OP_LDB:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := read(vm^, hi | lo)
			push(vm, Cell(value)) // Zero-extend byte to Cell

		case OP_LDW:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := read_word(vm^, hi | lo)
			push(vm, Cell(value)) // Zero-extend word to Cell

		case OP_LDD:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := read_dword(vm^, hi | lo)
			push(vm, Cell(value)) // Zero-extend dword to Cell

		case OP_LDQ:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := read_qword(vm^, hi | lo)
			push(vm, value) // Full Cell

		// Multi-width store operations
		case OP_STB:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := pop(vm) // Cell
			write(vm, hi | lo, u8(value)) // Truncate to byte

		case OP_STW:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := pop(vm) // Cell
			write_word(vm, hi | lo, Word(value)) // Truncate to word

		case OP_STD:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := pop(vm) // Cell
			write_dword(vm, hi | lo, DWord(value)) // Truncate to dword

		case OP_STQ:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := pop(vm) // Cell
			write_qword(vm, hi | lo, value) // Full Cell

		// Arithmetic operations (Cell-width)
		case OP_ADD:
			b := pop(vm)
			a := pop(vm)
			push(vm, a + b)
			update_status_flags(vm)
		case OP_SUB:
			b := pop(vm)
			a := pop(vm)
			push(vm, a - b)
			update_status_flags(vm)
		case OP_MUL:
			b := pop(vm)
			a := pop(vm)
			push(vm, a * b)
			update_status_flags(vm)
		case OP_DIV:
			b := pop(vm)
			a := pop(vm)
			if (b == 0) {
				log.warn("division by zero")
				return false
			}
			push(vm, a / b)
			update_status_flags(vm)
		case OP_INC:
			a := pop(vm)
			push(vm, a + 1)
			update_status_flags(vm)
		case OP_DEC:
			a := pop(vm)
			push(vm, a - 1)
			update_status_flags(vm)

		// Control flow
		case OP_JMP:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			vm.pc = hi | lo
		case OP_JSR:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			address := hi | lo

			// Call Kernel if address is greater or equal to 0xff00
			if address >= 0xff00 {
				call(vm, address) or_return
				continue
			}

			vm.rst[vm.rp] = vm.pc
			vm.rp += 1
			vm.pc = hi | lo
		case OP_RTS:
			vm.rp -= 1
			vm.pc = vm.rst[vm.rp]
		case OP_CMP:
			b := pop(vm)
			a := pop(vm)
			result := a - b
			if Cell(result) & Cell(0x8000_0000_0000_0000) != 0 {
				vm.status += {.N}
			} else {
				vm.status -= {.N}
			}
			if result == 0 {
				vm.status += {.Z}
			} else {
				vm.status -= {.Z}
			}
		case OP_BEQ:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			if .Z in vm.status {
				vm.pc = hi | lo
			}
		case OP_BNE:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			if !(.Z in vm.status) {
				vm.pc = hi | lo
			}
		case OP_HCF:
			log.warn("halted")
			return false
		case:
			log.warnf("invalid opcode: 0x%02x", op)
			return false
		}
	}
}
