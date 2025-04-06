package emulator

import "../../core/vm"
import "core:fmt"
import "core:log"
import "core:os"

main :: proc() {
	context.logger = log.create_console_logger()

	if len(os.args) < 2 {
		fmt.eprintln("usage: emulator ROMFILE")
		os.exit(-1)
	}

	input := os.args[1]
	bytecode, ok := os.read_entire_file_from_filename(input, context.temp_allocator)
	if !ok {
		fmt.eprintln("error reading input file")
		os.exit(-2)
	}

	machine: vm.VirtualMachine
	success := vm.evaluate(&machine, bytecode)
	if !success {
		os.exit(-3)
	}

	retval := vm.depth(machine) > 0 ? vm.peek(machine) : 0
	os.exit(int(retval))
}
