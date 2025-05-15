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
        variables: map[string]vm.Address
        data_section: vm.Address = 0x0200  // Start of data section
        data_offset: vm.Address = 0        // Current offset in data section

        defer delete(labels)
        defer delete(variables)

        pass1: [dynamic]scanner.Token
        defer delete(pass1)

        // First pass: collect labels and variables
        for token, index in tokens {
                if token.kind == .Label && !(token.lexeme in labels) {
                        labels[token.lexeme] = offset + vm.Address(index - len(labels) - len(variables))
                } else if token.kind == .Variable {
                        // Skip this token and get the variable name and size
                        if index + 2 < len(tokens) {
                                var_name := tokens[index + 1].lexeme
                                var_size := 1  // Default size is 1 byte

                                // Check if size is specified
                                if tokens[index + 2].kind == .Number {
                                        var_size = strconv.parse_int(tokens[index + 2].lexeme, 10) or_else 1
                                }

                                // Store variable address
                                variables[var_name] = data_section + data_offset
                                data_offset += vm.Address(var_size)

                                // Skip the processed tokens
                                index += 2
                        }
                } else if token.kind != .Data {  // Skip data directives for now
                        append(&pass1, token)
                }
        }

        // Second pass: process data directives
        data_values: [dynamic]struct {
                address: vm.Address,
                value: u8,
        }
        defer delete(data_values)

        for i := 0; i < len(tokens); i += 1 {
                if tokens[i].kind == .Data {
                        // Skip the DATA token and get the data values
                        if i + 2 < len(tokens) {
                                data_name := tokens[i + 1].lexeme

                                // Check if we have a variable name
                                if data_name in variables {
                                        data_addr := variables[data_name]
                                        i += 2  // Skip DATA and variable name

                                        // Process all following numbers until non-number token
                                        data_index := 0
                                        for i < len(tokens) && tokens[i].kind == .Number {
                                                value := parse_number(tokens[i]) or_else 0
                                                append(&data_values, {data_addr + vm.Address(data_index), u8(value)})
                                                data_index += 1
                                                i += 1
                                        }
                                        i -= 1  // Adjust for the outer loop increment
                                }
                        }
                }
        }

        parser := Parser {
                tokens   = pass1[:],
                position = 0,
                current  = pass1[0],
        }

        // Initialize data section with values
        for data in data_values {
                if len(bytecode) <= int(data.address) {
                        resize(&bytecode, int(data.address) + 1)
                }
                bytecode[data.address] = data.value
        }

        for {
                if parser.current.kind == .Mnemonic {
                        switch parser.current.lexeme {
                        case "BRK":
                                append(&bytecode, vm.OP_BRK)
                        case "PSH":
                                append(&bytecode, vm.OP_PSH)
                                next(&parser)
                                number := parse_number(parser.current) or_return
                                append(&bytecode, u8(number))
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
                        case "LDZ":
                                append(&bytecode, vm.OP_LDZ)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
                                append(&bytecode, u8(address))
                        case "STZ":
                                append(&bytecode, vm.OP_STZ)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
                                append(&bytecode, u8(address))
                        case "LDA":
                                append(&bytecode, vm.OP_LDA)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
                                hi := u8(address >> 8)
                                lo := u8(address)
                                append(&bytecode, hi)
                                append(&bytecode, lo)
                        case "STA":
                                append(&bytecode, vm.OP_STA)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
                                hi := u8(address >> 8)
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
                                address := get_address(parser.current, variables, labels) or_return
                                hi := u8(address >> 8)
                                lo := u8(address)
                                append(&bytecode, hi)
                                append(&bytecode, lo)
                        case "JSR":
                                append(&bytecode, vm.OP_JSR)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
                                hi := u8(address >> 8)
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
                                address := get_address(parser.current, variables, labels) or_return
                                hi := u8(address >> 8)
                                lo := u8(address)
                                append(&bytecode, hi)
                                append(&bytecode, lo)
                        case "BNE":
                                append(&bytecode, vm.OP_BNE)
                                next(&parser)
                                address := get_address(parser.current, variables, labels) or_return
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

// Add a function to handle variable references
get_address :: proc(token: scanner.Token, variables: map[string]vm.Address, labels: map[string]vm.Address) -> (address: vm.Address, success: bool) {
        if strings.starts_with(token.lexeme, "$") {
                // It's a hexadecimal number
                number, ok := parse_number(token)
                if !ok {
                        return 0, false
                }
                return vm.Address(number), true
        } else if token.lexeme in variables {
                // It's a variable reference
                return variables[token.lexeme], true
        } else if token.lexeme in labels {
                // It's a label reference
                return labels[token.lexeme], true
        }

        return 0, false
}

next :: proc(parser: ^Parser) -> bool {
        if parser.position >= len(parser.tokens) - 1 {
                return false
        }

        parser.position += 1
        parser.current = parser.tokens[parser.position]
        return true
}