# TypeScript Compiler - CS F365

A minimal TypeScript lexer built using Flex and GCC.

## Language: TypeScript

## Phase 1: Lexical Analysis

### Files
- `typescript_lexer.l` - Flex lexer implementation
- `valid_input.ts` - Valid TypeScript test program
- `error_input.ts` - TypeScript program with lexical errors

### How to Run
```bash
flex typescript_lexer.l
gcc lex.yy.c -o ts_lexer -lfl
./ts_lexer valid_input.ts
./ts_lexer error_input.ts
```

## Phase 2: Parsing & Code Generation
Coming soon.
