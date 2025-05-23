package scanner

import "core:log"
import "core:testing"

@(test)
should_scan :: proc(t: ^testing.T) {
	source := `
      psh $0
      psh 1
    loop:
      ovr
      ovr
      add
      cmp $e9
      bne loop
      brk
  `
	tokens, ok := scan(source)
	defer delete(tokens)

	testing.expect(t, ok)
	testing.expect_value(t, len(tokens), 13)
}
