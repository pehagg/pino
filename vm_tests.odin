package pino

import "core:testing"

@(test)
should_push_and_pop :: proc(t: ^testing.T) {
	vm: VirtualMachine
	push(&vm, 42)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, pop(&vm), 42)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_peek :: proc(t: ^testing.T) {
	vm: VirtualMachine
	push(&vm, 42)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, peek(vm), 42)
	testing.expect_value(t, depth(vm), 1)
}

@(test)
should_log_invalid_opcode :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{0xfe})
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_literal :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0xff, OP_BRK})
	testing.expect_value(t, depth(vm), 1)
}

@(test)
should_evaluate_dup :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_DUP, OP_BRK})
	testing.expect_value(t, depth(vm), 2)
}

@(test)
should_evaluate_swap :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_SWP, OP_BRK})
	testing.expect_value(t, pop(&vm), 2)
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_over :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_OVR, OP_BRK})
	testing.expect_value(t, pop(&vm), 2)
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, pop(&vm), 2)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_rotate :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_LIT, 0x04, OP_ROT, OP_BRK})
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, pop(&vm), 2)
	testing.expect_value(t, pop(&vm), 4)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_nip :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_NIP, OP_BRK})
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_tuck :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_TCK, OP_BRK})
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, pop(&vm), 2)
	testing.expect_value(t, pop(&vm), 3)
	testing.expect_value(t, depth(vm), 0)
}

@(test)
should_evaluate_write_and_load_zero_page :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x42, OP_STZ, 0x01, OP_LDZ, 0x01, OP_BRK})
	testing.expect_value(t, read(vm, 0x0001), 0x42)
	testing.expect_value(t, peek(vm), 0x42)
}

@(test)
should_evaluate_write_and_load :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x42, OP_STA, 0xff, 0x01, OP_LDA, 0xff, 0x01, OP_BRK})
	testing.expect_value(t, read(vm, 0xff01), 0x42)
	testing.expect_value(t, peek(vm), 0x42)
}

@(test)
should_evaluate_add :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_ADD, OP_BRK})
	testing.expect_value(t, peek(vm), 0x05)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, StatusFlag.N in vm.status, false)
	testing.expect_value(t, StatusFlag.Z in vm.status, false)
}

@(test)
should_evaluate_subtract :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_SUB, OP_BRK})
	testing.expect_value(t, peek(vm), 0xff)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, StatusFlag.N in vm.status, true)
	testing.expect_value(t, StatusFlag.Z in vm.status, false)
}

@(test)
should_evaluate_multiply :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_MUL, OP_BRK})
	testing.expect_value(t, peek(vm), 0x06)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, StatusFlag.N in vm.status, false)
	testing.expect_value(t, StatusFlag.Z in vm.status, false)
}

@(test)
should_evaluate_division :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x03, OP_DIV, OP_BRK})
	testing.expect_value(t, peek(vm), 0x00)
	testing.expect_value(t, depth(vm), 1)
	testing.expect_value(t, StatusFlag.N in vm.status, false)
	testing.expect_value(t, StatusFlag.Z in vm.status, true)
}

@(test)
should_evaluate_division_by_zero :: proc(t: ^testing.T) {
	vm: VirtualMachine
	evaluate(&vm, []u8{OP_LIT, 0x02, OP_LIT, 0x00, OP_DIV, OP_LIT, 0x03, OP_BRK})
	testing.expect_value(t, depth(vm), 0)
}
