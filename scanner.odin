package pino

import "core:log"
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

scan :: proc(source: string) -> (tokens: [dynamic]Token, success: bool) {
	scanner := Scanner {
		source   = source,
		position = 0,
		current  = rune(source[0]),
	}

	for {
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

	lexeme := strings.to_string(sb)
	token = {
		kind     = strings.ends_with(lexeme, ":") ? .Label : .Mnemonic,
		lexeme   = strings.ends_with(lexeme, ":") ? lexeme[:len(lexeme) - 1] : strings.to_upper(lexeme, context.temp_allocator),
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
