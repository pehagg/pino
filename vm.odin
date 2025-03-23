package pino

import "core:log"

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

Address :: distinct u16

VirtualMachine :: struct {
	wst: [256]u8,
	sp:  u8,
	mem: [65536]u8, // 64k
	pc:  u16,
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

write :: proc(vm: ^VirtualMachine, address: Address, value: u8) {
	vm.mem[address] = value
}

fetch :: proc(vm: ^VirtualMachine) -> u8 {
	op := vm.mem[vm.pc]
	vm.pc += 1
	return op
}

evaluate :: proc(vm: ^VirtualMachine, code: []u8) {
	for i in 0 ..< len(code) {
		vm.mem[0x0100 + i] = code[i]
	}

	vm.sp = 0
	vm.pc = 0x0100

	for {
		op := fetch(vm)
		switch op {
		case OP_BRK:
			return
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
		case:
			log.warnf("invalid opcode: 0x%02x", op)
			return
		}
	}
}
