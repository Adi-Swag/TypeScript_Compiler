# TypeScript Compiler — CS F365 Compiler Construction

A minimal TypeScript compiler built using **Flex** and **Bison**, implementing lexical analysis, syntax parsing, and three address code generation.

---

## Language: TypeScript

---

## Project Structure

```
TypeScript_Compiler/
│
├── Phase 1 — Lexical Analysis
│   ├── typescript_lexer.l        # Flex lexer (standalone, prints token stream)
│   ├── valid_input.ts            # Valid TypeScript test program
│   └── error_input.ts            # TypeScript program with lexical errors
│
└── Phase 2 — Parsing & TAC Generation
    ├── typescript_parser.y       # Bison parser (syntax analysis)
    ├── typescript_lexer_v2.l     # Flex lexer for parser (returns token codes)
    ├── typescript_tac.y          # Bison parser + Three Address Code generator
    ├── typescript_lexer_tac.l    # Flex lexer for TAC generator
    ├── Makefile                  # Builds the parser (ts_compiler)
    └── Makefile_tac              # Builds the TAC generator (ts_tac)
```

---

## Phase 1: Lexical Analysis

### How to Build & Run

```bash
# Install dependencies
sudo apt-get install flex gcc

# Generate and compile
flex typescript_lexer.l
gcc lex.yy.c -o ts_lexer -lfl

# Run on valid input
./ts_lexer valid_input.ts

# Run on input with lexical errors
./ts_lexer error_input.ts
```

### Sample Output

```
=============================================================
        Minimal TypeScript Lexer  --  Token Stream
=============================================================
LINE   TOKEN TYPE            LEXEME
-------------------------------------------------------------
4      KW_LET                let
4      IDENTIFIER            x
4      COLON                 :
4      TYPE_NUMBER           number
4      OP_ASSIGN             =
4      NUM_LIT               10
4      SEMICOLON             ;
...
=============================================================
  Total tokens  : 87
  Lexical errors: 0
=============================================================
```

---

## Phase 2: Parsing & Three Address Code Generation

### Parser (Syntax Analysis)

```bash
# Install dependencies
sudo apt-get install bison flex gcc

# Build
make

# Test valid input
make run_valid

# Test input with syntax errors
make run_error

# Clean generated files
make clean
```

### Three Address Code Generator

```bash
# Build
make -f Makefile_tac

# Test valid input
make -f Makefile_tac run_valid

# Test input with errors
make -f Makefile_tac run_error

# Clean
make -f Makefile_tac clean
```

### Sample TAC Output

For input:
```typescript
let x: number = 10;
x = x + y * 2;
if (x > 0) { ... } else { ... }
while (i < 10) { i = i + 1; }
```

Generated TAC:
```
    x = 10
    t1 = y * 2
    t2 = x + t1
    x = t2
    t3 = x > 0
    if_false t3 goto L1
    goto L2
L1:
L2:
L3:
    t4 = i < 10
    if_false t4 goto L4
    t5 = i + 1
    i = t5
    goto L3
L4:
```

---

## CFG Summary

The language supports:

- **Variable declaration** — `let` and `const` with type annotations
- **Assignment statements**
- **Expressions** — arithmetic, relational, logical with 5 precedence levels
- **Conditional** — `if`, `if-else`, `if-else-if` chains
- **Loop** — `while`
- **Types** — `number`, `string`, `boolean`

---

## Tags

| Tag | Description |
|-----|-------------|
| `v1.0-phase1` | Phase 1 complete — Lexer |
| `v2.0-phase2` | Phase 2 complete — Parser + TAC |
