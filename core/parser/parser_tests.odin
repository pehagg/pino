package parser

import "../scanner"
import "core:log"
import "core:testing"

@(test)
should_parse :: proc(t: ^testing.T) {
	source := `
      pshb $0
      pshb 1
    loop:
      ovr
      ovr
      add
      pshb $e9
      cmp
      bne loop
      brk
  `
	tokens, scan_success := scanner.scan(source)
	defer delete(tokens)

	testing.expect(t, scan_success)

	bytecode, ok := parse(tokens[:])
	defer delete(bytecode)

	testing.expect(t, ok)
	testing.expect_value(t, len(bytecode), 14)  // Added pshb $e9, so +2 bytes, removed cmp arg, so -1 byte = +1 total
}
