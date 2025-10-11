package scanner

import "core:log"
import "core:testing"

@(test)
should_scan :: proc(t: ^testing.T) {
	source := `
      pshb 0
      pshb 1
    loop:
      ovr
      ovr
      add
      dup
      pshb 233
      cmp
      bne loop
      brk
  `
	tokens, ok := scan(source)
	defer delete(tokens)

	testing.expect(t, ok)
	testing.expect_value(t, len(tokens), 15)
}
