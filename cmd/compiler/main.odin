package compiler

import "../../core/parser"
import "../../core/scanner"
import "../../core/vm"
import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) < 3 {
		fmt.eprintln("usage: compiler INPUT OUTPUT")
		return
	}

	input := os.args[1]
	source, read_ok := os.read_entire_file_from_filename(input, context.temp_allocator)
	if !read_ok {
		fmt.eprintln("error reading input")
		return
	}

	tokens, scan_ok := scanner.scan(string(source))
	defer delete(tokens)
	if !scan_ok {
		fmt.eprintln("error scanning code")
		return
	}

	bytecode, parse_ok := parser.parse(tokens[:])
	defer delete(bytecode)
	if !parse_ok {
		fmt.eprintln("error parsing code")
		return
	}

	output := os.args[2]
	write_ok := os.write_entire_file(output, bytecode[:])
	if !write_ok {
		fmt.eprintln("error writing bytecode")
		return
	}

	fmt.println("much success!")
}
