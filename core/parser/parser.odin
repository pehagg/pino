package parser

import "../scanner"
import "../vm"
import "core:log"
import "core:strconv"
import "core:strings"

Parser :: struct {
	tokens:   []scanner.Token,
	position: int,
	current:  scanner.Token,
}

parse :: proc(tokens: []scanner.Token) -> (bytecode: [dynamic]u8, success: bool) {
	offset: vm.Address = 0x0100
	labels: map[string]vm.Address
	defer delete(labels)

	pass1: [dynamic]scanner.Token
	defer delete(pass1)

	for token, index in tokens {
		if token.kind == .Label && !(token.lexeme in labels) {
			labels[token.lexeme] = offset + vm.Address(index - len(labels))
		} else {
			append(&pass1, token)
		}
	}

	parser := Parser {
		tokens   = pass1[:],
		position = 0,
		current  = pass1[0],
	}

	for {
		if parser.current.kind == .Mnemonic {
			switch parser.current.lexeme {
			case "BRK":
				append(&bytecode, vm.OP_BRK)

			// Multi-width push operations
			case "PSHB":
				append(&bytecode, vm.OP_PSHB)
				next(&parser)
				number := parse_number(parser.current) or_return
				append(&bytecode, u8(number))  // 1 byte
				
			case "PSHW":
				append(&bytecode, vm.OP_PSHW)
				next(&parser)
				number := parse_number(parser.current) or_return
				value := vm.Word(number)
				append(&bytecode, u8(value >> 8))   // High byte
				append(&bytecode, u8(value))        // Low byte
				
			case "PSHD":
				append(&bytecode, vm.OP_PSHD)
				next(&parser)
				number := parse_number(parser.current) or_return
				value := vm.DWord(number)
				for i in 0..<4 {
					append(&bytecode, u8(value >> vm.DWord(8 * (3-i))))
				}
				
			case "PSHQ":
				append(&bytecode, vm.OP_PSHQ)
				next(&parser)
				number := parse_number(parser.current) or_return
				value := vm.Cell(number)
				for i in 0..<8 {
					append(&bytecode, u8(value >> vm.Cell(8 * (7-i))))
				}

			// Stack operations
			case "POP":
				append(&bytecode, vm.OP_POP)
			case "DUP":
				append(&bytecode, vm.OP_DUP)
			case "SWP":
				append(&bytecode, vm.OP_SWP)
			case "OVR":
				append(&bytecode, vm.OP_OVR)
			case "ROT":
				append(&bytecode, vm.OP_ROT)
			case "NIP":
				append(&bytecode, vm.OP_NIP)
			case "TCK":
				append(&bytecode, vm.OP_TCK)

			// Multi-width load operations
			case "LDB":
				append(&bytecode, vm.OP_LDB)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "LDW":
				append(&bytecode, vm.OP_LDW)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "LDD":
				append(&bytecode, vm.OP_LDD)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "LDQ":
				append(&bytecode, vm.OP_LDQ)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			// Multi-width store operations
			case "STB":
				append(&bytecode, vm.OP_STB)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "STW":
				append(&bytecode, vm.OP_STW)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "STD":
				append(&bytecode, vm.OP_STD)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			case "STQ":
				append(&bytecode, vm.OP_STQ)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)

			// Arithmetic operations
			case "ADD":
				append(&bytecode, vm.OP_ADD)
			case "SUB":
				append(&bytecode, vm.OP_SUB)
			case "MUL":
				append(&bytecode, vm.OP_MUL)
			case "DIV":
				append(&bytecode, vm.OP_DIV)
			case "INC":
				append(&bytecode, vm.OP_INC)
			case "DEC":
				append(&bytecode, vm.OP_DEC)

			// Control flow
			case "JMP":
				append(&bytecode, vm.OP_JMP)
				next(&parser)
				if strings.starts_with(parser.current.lexeme, "$") {
					address := parse_number(parser.current) or_return
					hi := u8(address >> 8)
					lo := u8(address)
					append(&bytecode, hi)
					append(&bytecode, lo)
				} else {
					address := labels[parser.current.lexeme]
					hi := u8(address >> 8)
					lo := u8(address)
					append(&bytecode, hi)
					append(&bytecode, lo)
				}
			case "JSR":
				append(&bytecode, vm.OP_JSR)
				next(&parser)
				if strings.starts_with(parser.current.lexeme, "$") {
					address := parse_number(parser.current) or_return
					hi := u8(address >> 8)
					lo := u8(address)
					append(&bytecode, hi)
					append(&bytecode, lo)
				} else {
					address := labels[parser.current.lexeme]
					hi := u8(address >> 8)
					lo := u8(address)
					append(&bytecode, hi)
					append(&bytecode, lo)
				}
			case "RTS":
				append(&bytecode, vm.OP_RTS)
			case "CMP":
				append(&bytecode, vm.OP_CMP)
			case "BEQ":
				append(&bytecode, vm.OP_BEQ)
				next(&parser)
				address := labels[parser.current.lexeme]
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "BNE":
				append(&bytecode, vm.OP_BNE)
				next(&parser)
				address := labels[parser.current.lexeme]
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "HCF":
				append(&bytecode, vm.OP_HCF)
			}
		}

		if ok := next(&parser); !ok {
			success = true
			return
		}
	}
}

parse_number :: proc(token: scanner.Token) -> (n: int, success: bool) {
	if token.kind != .Number {
		return {}, false
	}

	base := token.lexeme[0] == '$' ? 16 : 10
	number := base == 16 ? token.lexeme[1:] : token.lexeme[:]
	n = strconv.parse_int(number, base) or_return
	success = true
	return
}

next :: proc(parser: ^Parser) -> bool {
	if parser.position >= len(parser.tokens) - 1 {
		return false
	}

	parser.position += 1
	parser.current = parser.tokens[parser.position]
	return true
}
