package pino

import "core:log"

OP_BRK :: 0x00
OP_LIT :: 0x01
OP_DRP :: 0x02
OP_DUP :: 0x03
OP_SWP :: 0x04
OP_OVR :: 0x05
OP_ROT :: 0x06
OP_NIP :: 0x07
OP_TCK :: 0x08

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
		case:
			log.warnf("invalid opcode: 0x%02x", op)
			return
		}
	}
}

fetch :: proc(vm: ^VirtualMachine) -> u8 {
	op := vm.mem[vm.pc]
	vm.pc += 1
	return op
}
