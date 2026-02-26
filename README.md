# TypeScript Compiler — CS F365 Compiler Construction

A minimal TypeScript compiler built using **Flex** (lexer) and **Bison** (parser) as part of the CS F365 Compiler Construction course assignment.

---

**Language chosen:** TypeScript

---

## Repository Structure

```
TypeScript_Compiler/
│
├── Phase 1 — Lexical Analysis
│   ├── typescript_lexer.l       # Flex lexer (standalone, prints token stream)
│   ├── valid_input.ts           # Valid TypeScript test program
│   └── error_input.ts           # TypeScript program with lexical errors
│
├── Phase 2 — Parsing
│   ├── typescript_parser.y      # Bison parser (grammar + syntax analysis)
│   ├── typescript_lexer_p2.l    # Updated Flex lexer (returns token codes to parser)
│   └── Makefile                 # Build system for Phase 2
│
└── README.md
```

---

## Phase 1 — Lexical Analysis

### What it does
- Tokenizes a minimal TypeScript program
- Recognizes keywords, identifiers, literals, operators, and delimiters
- Reports lexical errors (unrecognized characters) with line numbers
- Prints a formatted token stream to stdout

### Prerequisites
```bash
sudo apt-get install flex gcc
```

### Build & Run

```bash
# Generate C code from lexer
flex typescript_lexer.l

# Compile
gcc lex.yy.c -o ts_lexer -lfl

# Run on valid input
./ts_lexer valid_input.ts

# Run on input with lexical errors
./ts_lexer error_input.ts
```

### Sample Output (valid input)
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

## Phase 2 — Parsing & Syntax Analysis

### What it does
- Parses the token stream produced by the lexer
- Validates program structure against the TypeScript CFG
- Reports syntax errors with line numbers and continues parsing (error recovery)
- Prints a parse trace showing each recognized construct

### Prerequisites
```bash
sudo apt-get install bison flex gcc
```

### Build & Run

```bash
# Build everything (bison + flex + gcc)
make

# Test with valid input
make run_valid

# Test with syntax errors
make run_error

# Clean all generated files
make clean
```

### Manual Build (without make)
```bash
bison -d typescript_parser.y          # generates typescript_parser.tab.c and .h
flex typescript_lexer_p2.l            # generates lex.yy.c
gcc typescript_parser.tab.c lex.yy.c -o ts_compiler -lfl
./ts_compiler valid_input.ts
./ts_compiler error_input.ts
```

### Sample Output (valid input)
```
=============================================================
     Minimal TypeScript Parser  --  Syntax Analysis
=============================================================

[DECL] 'x' declared with initializer.
[DECL] 'y' declared with initializer.
[ASSIGN] Assignment to 'x'.
[IF] if-else parsed.
[WHILE] while loop parsed.

[OK] Program is syntactically valid.
-------------------------------------------------------------
  Result : SUCCESS — No syntax errors found.
=============================================================
```

### Sample Output (error input)
```
[SYNTAX ERROR] Line 7: syntax error
[SYNTAX ERROR] Line 10: syntax error
...
-------------------------------------------------------------
  Result : FAILED  — 2 syntax error(s) found.
=============================================================
```

---

## Phase 3 — Three Address Code Generation
> Coming soon (Deadline: 16 April 2026)

---

## CFG Summary

The compiler supports a minimal subset of TypeScript:

| Construct | Example |
|-----------|---------|
| Variable declaration | `let x: number = 10;` |
| Assignment | `x = x + 1;` |
| Arithmetic expressions | `x * y + z % 2` |
| Relational expressions | `x >= 5` |
| Logical expressions | `flag && (x > 0)` |
| If-else | `if (x > 0) { ... } else { ... }` |
| While loop | `while (i < 10) { ... }` |

**Operator precedence (low → high):** `\|\|` → `&&` → relational → `+/-` → `*/%` → unary

---

## Submission Deadlines

| Phase | Deadline |
|-------|----------|
| Phase 1 — Lexical Analysis | 03 March 2026, 5:00 PM |
| Phase 2 — Parsing + TAC | 16 April 2026, 5:00 PM |
