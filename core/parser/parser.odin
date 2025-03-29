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
		if token.kind == .Label {
			labels[token.lexeme] = offset + vm.Address(index - len(labels))
		} else {
			append(&pass1, token)
		}
	}

	parser := Parser {
		tokens   = pass1[:],
		position = 0,
		current  = tokens[0],
	}

	for {
		if parser.current.kind == .Mnemonic {
			switch parser.current.lexeme {
			case "BRK":
				append(&bytecode, vm.OP_BRK)
			case "LIT":
				append(&bytecode, vm.OP_LIT)
				next(&parser)
				number := parse_number(parser.current) or_return
				append(&bytecode, u8(number))
			case "DRP":
				append(&bytecode, vm.OP_DRP)
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
			case "LDZ":
				append(&bytecode, vm.OP_LDZ)
				next(&parser)
				address := parse_number(parser.current) or_return
				append(&bytecode, u8(address))
			case "STZ":
				append(&bytecode, vm.OP_STZ)
				next(&parser)
				address := parse_number(parser.current) or_return
				append(&bytecode, u8(address))
			case "LDA":
				append(&bytecode, vm.OP_LDA)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address) << 8
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "STA":
				append(&bytecode, vm.OP_STA)
				next(&parser)
				address := parse_number(parser.current) or_return
				hi := u8(address) << 8
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
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
			case "JMP":
				append(&bytecode, vm.OP_JMP)
				next(&parser)
				address := labels[parser.current.lexeme]
				hi := u8(address) << 8
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "JSR":
				append(&bytecode, vm.OP_JSR)
				next(&parser)
				address := labels[parser.current.lexeme]
				hi := u8(address) << 8
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "RTS":
				append(&bytecode, vm.OP_RTS)
			case "CMP":
				append(&bytecode, vm.OP_CMP)
				next(&parser)
				number := parse_number(parser.current) or_return
				append(&bytecode, u8(number))
			case "BEQ":
				append(&bytecode, vm.OP_BEQ)
				next(&parser)
				// FIXME: labels are parsed as mnemonics
				address := labels[strings.to_lower(parser.current.lexeme, context.temp_allocator)]
				hi := u8(address >> 8)
				lo := u8(address)
				append(&bytecode, hi)
				append(&bytecode, lo)
			case "BNE":
				append(&bytecode, vm.OP_BNE)
				next(&parser)
				// FIXME: labels are parsed as mnemonics
				address := labels[strings.to_lower(parser.current.lexeme, context.temp_allocator)]
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
