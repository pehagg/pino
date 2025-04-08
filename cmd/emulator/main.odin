package emulator

import "../../core/vm"
import "core:fmt"
import "core:log"
import "core:os"
import rl "vendor:raylib"

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

	rl.InitWindow(800, 600, "Pino")
	rl.SetTargetFPS(60)

	machine: vm.VirtualMachine
	machine.font = rl.LoadFont("assets/fonts/SpaceMono-Regular.ttf")

	success := vm.evaluate(&machine, bytecode, false)
	rl.CloseWindow()

	if !success {
		os.exit(-3)
	}

	retval := vm.depth(machine) > 0 ? vm.peek(machine) : 0
	os.exit(int(retval))
}
