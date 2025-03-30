package scanner

import "core:log"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode"

Scanner :: struct {
	source:   string,
	position: int,
	current:  rune,
}

Token :: struct {
	kind:     TokenKind,
	lexeme:   string,
	position: int,
}

TokenKind :: enum {
	Number,
	Mnemonic,
	Label,
}

mnemonics :: []string {
	"BRK",
	"LIT",
	"DRP",
	"DUP",
	"SWP",
	"OVR",
	"ROT",
	"NIP",
	"TCK",
	"LDZ",
	"STZ",
	"LDA",
	"STA",
	"ADD",
	"SUB",
	"MUK",
	"DIV",
	"INC",
	"DEC",
	"CLC",
	"SEC",
	"JMP",
	"JSR",
	"RTS",
	"CMP",
	"BEQ",
	"BNE",
	"HCF",
}

scan :: proc(source: string) -> (tokens: [dynamic]Token, success: bool) {
	scanner := Scanner {
		source   = source,
		position = 0,
		current  = rune(source[0]),
	}

	main_loop: for {
		if scanner.current == ';' {
			inner: for scanner.current != '\n' {
				if ok := advance(&scanner); ok {
					continue inner
				}
			}
		}

		if unicode.is_white_space(scanner.current) {
			if ok := advance(&scanner); ok {
				continue
			}
		}

		if unicode.is_digit(scanner.current) || scanner.current == '$' {
			base := scanner.current == '$' ? 16 : 10
			if token, ok := scan_number(&scanner, base); ok {
				append(&tokens, token)
			}
			continue
		}

		if unicode.is_letter(scanner.current) {
			if token, ok := scan_identifier(&scanner); ok {
				append(&tokens, token)
			}
			continue
		}

		if ok := advance(&scanner); !ok {
			return tokens, true
		}
	}
}

scan_number :: proc(scanner: ^Scanner, base: int = 10) -> (token: Token, success: bool) {
	sb: strings.Builder
	strings.builder_init(&sb, context.temp_allocator)

	position := scanner.position
	strings.write_rune(&sb, scanner.current)

	for {
		if ok := advance(scanner); ok {
			if unicode.is_digit(scanner.current) ||
			   (base == 16 && scanner.current >= 'a' && scanner.current <= 'f') {
				strings.write_rune(&sb, scanner.current)
				continue
			}
			break
		}
		break
	}

	token = {
		kind     = .Number,
		lexeme   = strings.to_string(sb),
		position = position,
	}
	success = true
	return
}

scan_identifier :: proc(scanner: ^Scanner) -> (token: Token, success: bool) {
	sb: strings.Builder
	strings.builder_init(&sb, context.temp_allocator)

	position := scanner.position
	strings.write_rune(&sb, scanner.current)

	for {
		if ok := advance(scanner); ok {
			if unicode.is_letter(scanner.current) || scanner.current == ':' {
				strings.write_rune(&sb, scanner.current)
				continue
			}
			break
		}
		break
	}

	kind :: proc(lexeme: string) -> TokenKind {
		if slice.contains(mnemonics, lexeme) {
			return .Mnemonic
		} else if strings.ends_with(lexeme, ":") {
			return .Label
		} else {
			return .Label
		}
	}

	lexeme := strings.to_string(sb)
	token = {
		kind     = kind(strings.to_upper(lexeme, context.temp_allocator)),
		lexeme   = strings.ends_with(lexeme, ":") ? strings.to_upper(lexeme[:len(lexeme) - 1], context.temp_allocator) : strings.to_upper(lexeme, context.temp_allocator),
		position = position,
	}
	success = true
	return
}

advance :: proc(scanner: ^Scanner) -> bool {
	if scanner.position >= len(scanner.source) - 1 {
		return false
	}

	scanner.position += 1
	scanner.current = rune(scanner.source[scanner.position])
	return true
}
