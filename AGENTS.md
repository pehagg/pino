# Pino Codebase Guide for Agents

## Build & Test Commands
- **Build**: `./build.sh` (builds compiler and emulator to bin/)
- **Test All**: `./test.sh` (runs all tests)  
- **Test Single Module**: `odin test core/vm`, `odin test core/scanner`, `odin test core/parser`
- **Clean**: `./clean.sh` (removes bin/ and temp files)

## Code Style Guidelines
- **Language**: Odin programming language
- **Naming**: snake_case for variables/functions, PascalCase for types/structs
- **Imports**: Group core imports, then vendor, then relative imports
- **Types**: Explicit typing preferred, use distinct types for clarity (e.g., `Address :: distinct u16`)
- **Error Handling**: Use explicit success booleans, `or_return` for error propagation
- **Comments**: Use `/*` block comments for procedures with inputs/outputs documentation
- **Constants**: ALL_CAPS with OP_ prefix for opcodes (e.g., `OP_BRK :: 0x00`)
- **Testing**: Use `@(test)` attribute, `testing.expect()` for assertions
- **Memory**: Use `context.temp_allocator` for temporary allocations, explicit cleanup with `defer`

## Project Structure
- `core/`: VM components (vm, scanner, parser with tests)  
- `cmd/`: Executables (compiler, emulator)
- `examples/`: Assembly sample programs (.asm files)