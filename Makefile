# ============================================================
# Makefile for Minimal TypeScript Compiler
# CS F365 - Compiler Construction - Phase 2
#
# Usage:
#   make            — build everything
#   make run_valid  — test with valid input
#   make run_error  — test with error input
#   make clean      — remove generated files
# ============================================================

CC      = gcc
CFLAGS  = -Wall -g

TARGET  = ts_compiler

all: $(TARGET)

# Step 1: Run bison to generate parser C code + header
typescript_parser.tab.c typescript_parser.tab.h: typescript_parser.y
	bison -d typescript_parser.y

# Step 2: Run flex to generate lexer C code
lex.yy.c: typescript_lexer_p2.l typescript_parser.tab.h
	flex typescript_lexer_p2.l

# Step 3: Compile everything into one executable
$(TARGET): typescript_parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) typescript_parser.tab.c lex.yy.c -o $(TARGET) -lfl

# ── Run targets ─────────────────────────────────────────────
run_valid: $(TARGET)
	@echo "============================================================="
	@echo "  Testing with VALID input"
	@echo "============================================================="
	./$(TARGET) valid_input.ts

run_error: $(TARGET)
	@echo "============================================================="
	@echo "  Testing with ERROR input"
	@echo "============================================================="
	./$(TARGET) error_input.ts

# ── Clean ────────────────────────────────────────────────────
clean:
	rm -f typescript_parser.tab.c typescript_parser.tab.h \
	      lex.yy.c $(TARGET)
