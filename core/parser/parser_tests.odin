package parser

import "../scanner"
import "core:log"
import "core:testing"

@(test)
should_parse :: proc(t: ^testing.T) {
	source := `
      lit $0
      lit 1
    loop:
      ovr
      ovr
      add
      cmp $e9
      bne loop
      brk
  `
	tokens, scan_success := scanner.scan(source)
	defer delete(tokens)

	testing.expect(t, scan_success)

	bytecode, ok := parse(tokens[:])
	defer delete(bytecode)

	testing.expect(t, ok)
	testing.expect_value(t, len(bytecode), 13)
}
