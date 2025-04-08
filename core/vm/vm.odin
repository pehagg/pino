package vm

import "core:fmt"
import "core:log"
import "core:strings"
import rl "vendor:raylib"

OP_BRK :: 0x00 // Break
OP_LIT :: 0x01 // Push literal (1 byte) to stack ( -- a)
OP_DRP :: 0x02 // Drop top-most item from stack (a b -- a)
OP_DUP :: 0x03 // Duplicate top-most item in stack (a -- a a)
OP_SWP :: 0x04 // Swap two top-most items (a b -- b a)
OP_OVR :: 0x05 // Push second to top-most item to top (a b -- a b a)
OP_ROT :: 0x06 // Rotate three top-most items left (a b c -- c a b)
OP_NIP :: 0x07 // Drop second item in stack ( a b -- b)
OP_TCK :: 0x08 // Push top-most item to third place (a b -- b a b)
OP_LDZ :: 0x11 // Load value (1 byte) from zero page to top of stack
OP_STZ :: 0x12 // Store value (1 byte) from stack to zero page
OP_LDA :: 0x13 // Load value (1 byte) from memory to top of stack
OP_STA :: 0x14 // Store value (1 byte) from stack to memory
OP_ADD :: 0x20 // Add two top-most items (a b -- a+b)
OP_SUB :: 0x21 // Subtract two top-most items (a b -- a-b)
OP_MUL :: 0x22 // Multiply two top-most items (a b -- a*b)
OP_DIV :: 0x23 // Divide two top-most items (a b -- a/b)
OP_INC :: 0x24 // Increment top-most value by one (a -- a+1)
OP_DEC :: 0x25 // Decrement top-most value by one (a -- a-1)
OP_CLC :: 0x30 // Reserved
OP_SEC :: 0x31 // Reserved
OP_JMP :: 0x40 // Jump to address explicitly
OP_JSR :: 0x41 // Jump to subroutine; pushes return address to rst 
OP_RTS :: 0x42 // Return from subroutine
OP_CMP :: 0x43 // Compare value with top-most value (not consumed), set N and Z flags accordingly 
OP_BEQ :: 0x44 // Branch to address if top-most value is non-zero (a b -- a), where b != 0
OP_BNE :: 0x45 // Branch to address if top-most value is zero (a b -- a), where b == 0
OP_HCF :: 0xff // Halt execution

Address :: distinct u16

ADDR_CHROUT :: 0xff00
ADDR_BGNDRW :: 0xff10
ADDR_ENDDRW :: 0xff11
ADDR_PIXOUT :: 0xff12
ADDR_LINOUT :: 0xff13
ADDR_TXTOUT :: 0xff14
ADDR_PALETT :: 0xff20

StatusFlag :: enum {
	N, // Negative
	V, // Overflow
	Z, // Zero
	C, // Carry
}

StatusRegister :: bit_set[StatusFlag;u8]

VirtualMachine :: struct {
	wst:      [256]u8,
	sp:       u8,
	rst:      [256]Address,
	rp:       u8,
	mem:      [65536]u8, // 64k
	pc:       Address,
	status:   StatusRegister,
	headless: bool,
	font:     rl.Font,
}

push :: proc(vm: ^VirtualMachine, value: u8) {
	vm.wst[vm.sp] = value
	vm.sp += 1
}

pop :: proc(vm: ^VirtualMachine) -> u8 {
	vm.sp -= 1
	return vm.wst[vm.sp]
}

peek :: proc(vm: VirtualMachine) -> u8 {
	return vm.wst[vm.sp - 1]
}

depth :: proc(vm: VirtualMachine) -> u8 {
	return vm.sp
}

read :: proc(vm: VirtualMachine, address: Address) -> u8 {
	return vm.mem[address]
}

read_4 :: proc(vm: VirtualMachine, address: Address) -> u32 {
	a := u32(read(vm, address + 0)) << 24
	b := u32(read(vm, address + 1)) << 16
	c := u32(read(vm, address + 2)) << 8
	d := u32(read(vm, address + 3))
	return a | b | c | d
}

write :: proc(vm: ^VirtualMachine, address: Address, value: u8) {
	vm.mem[address] = value
}

write_4 :: proc(vm: ^VirtualMachine, address: Address, value: u32) {
	write(vm, address + 0, u8(value >> 24))
	write(vm, address + 1, u8(value >> 16))
	write(vm, address + 2, u8(value >> 8))
	write(vm, address + 3, u8(value))
}

call :: proc(vm: ^VirtualMachine, address: Address) -> bool {
	switch address {
	case ADDR_CHROUT:
		char := pop(vm)
		fmt.print(rune(char))
	case ADDR_BGNDRW:
		if vm.headless do return false
		rl.BeginDrawing()
	case ADDR_ENDDRW:
		if vm.headless do return false
		rl.EndDrawing()
	case ADDR_PIXOUT:
		if vm.headless do return false
		palette_color := pop(vm)
		y := pop(vm)
		x := pop(vm)
		rl.DrawPixel(i32(x), i32(y), color(vm^, palette_color))
	case ADDR_LINOUT:
		if vm.headless do return false
		palette_color := pop(vm)
		end_y := pop(vm)
		end_x := pop(vm)
		start_y := pop(vm)
		start_x := pop(vm)
		rl.DrawLine(i32(start_x), i32(start_y), i32(end_x), i32(end_y), color(vm^, palette_color))
	case ADDR_TXTOUT:
		if vm.headless do return false
		palette_color := pop(vm)
		color := color(vm^, palette_color)
		y := pop(vm)
		x := pop(vm)
		char := pop(vm)
		position := rl.Vector2{f32(x), f32(y)}
		bytes := []u8{char}
		sb: strings.Builder
		defer strings.builder_destroy(&sb)
		strings.write_rune(&sb, rune(char))
		cstr, _ := strings.to_cstring(&sb)
		rl.DrawTextEx(vm.font, cstr, position, 20, 0, color)
	case:
		log.warn("invalid call to address:", address)
		return false
	}

	return true
}

fetch :: proc(vm: ^VirtualMachine) -> u8 {
	op := vm.mem[vm.pc]
	vm.pc += 1
	return op
}

update_status_flags :: proc(vm: ^VirtualMachine) {
	value := peek(vm^)

	// negative number if MSB is one
	if value & 0x80 == 0x80 {
		vm.status += {.N}
	} else {
		vm.status -= {.N}
	}

	if value == 0 {
		vm.status += {.Z}
	} else {
		vm.status -= {.Z}
	}
}

color :: proc(vm: VirtualMachine, palette: u8) -> rl.Color {
	address := ADDR_PALETT + Address(palette * 4)
	value := read_4(vm, address)
	return rl.GetColor(value)
}

evaluate :: proc(vm: ^VirtualMachine, code: []u8, headless: bool = true) -> bool {
	vm.headless = headless

	// initialize colors
	write_4(vm, ADDR_PALETT + 0, 0x000000ff) // black
	write_4(vm, ADDR_PALETT + 4, 0xffffffff) // white
	write_4(vm, ADDR_PALETT + 8, 0xff0000ff) // red
	write_4(vm, ADDR_PALETT + 12, 0x37848bff) // cyan

	// copy bytecode to memory at 0x0100 (page 2)
	for i in 0 ..< len(code) {
		vm.mem[0x0100 + i] = code[i]
	}

	// reset pointers
	vm.sp = 0
	vm.pc = 0x0100
	vm.rp = 0

	for {
		if !vm.headless && rl.WindowShouldClose() {
			return true
		}

		op := fetch(vm)
		switch op {
		case OP_BRK:
			return true
		case OP_LIT:
			literal := fetch(vm)
			push(vm, literal)
		case OP_DRP:
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
		case OP_LDZ:
			address := Address(fetch(vm))
			value := read(vm^, address)
			push(vm, value)
		case OP_STZ:
			address := Address(fetch(vm))
			value := pop(vm)
			write(vm, address, value)
		case OP_LDA:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := read(vm^, hi | lo)
			push(vm, value)
		case OP_STA:
			hi := Address(fetch(vm)) << 8
			lo := Address(fetch(vm))
			value := pop(vm)
			write(vm, hi | lo, value)
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
			a := peek(vm^)
			b := fetch(vm)
			result := a - b
			if result < 0 {
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
