%{
/*
 * Lexer for Minimal TypeScript
 * CS F365 - Compiler Construction
 * Tool: Flex (Lex)
 *
 * Compile:  flex typescript_lexer.l
 *           gcc lex.yy.c -o ts_lexer -lfl
 * Run:      ./ts_lexer < input.ts
 *       OR  ./ts_lexer input.ts
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int token_count = 0;
int error_count = 0;
int line_num    = 1;

void print_token(const char *type, const char *value) {
    printf("%-5d  %-20s  %s\n", line_num, type, value);
    token_count++;
}
%}

/* ── Lex Options ─────────────────────────────────────────── */
%option noyywrap

/* ── Named Definitions ───────────────────────────────────── */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]

INTEGER     {DIGIT}+
DECIMAL     {DIGIT}+\.{DIGIT}+
NUMBER_LIT  {DECIMAL}|{INTEGER}

STRING_LIT  \"([^\"\\]|\\.)*\"

ID          {LETTER}{ALNUM}*

WHITESPACE  [ \t\r]+
NEWLINE     \n

SL_COMMENT  \/\/[^\n]*
ML_COMMENT  \/\*([^*]|\*+[^*/])*\*+\/

%%

 /* ── 1. Whitespace & Comments (skip) ────────────────────── */

{WHITESPACE}    { /* skip */ }
{NEWLINE}       { line_num++; }
{SL_COMMENT}    { /* skip single-line comment */ }
{ML_COMMENT}    {
                    for (char *p = yytext; *p; p++)
                        if (*p == '\n') line_num++;
                }

 /* ── 2. Multi-character Operators (before single-char) ──── */

"=="    { print_token("OP_EQ",     yytext); }
"!="    { print_token("OP_NEQ",    yytext); }
"<="    { print_token("OP_LTE",    yytext); }
">="    { print_token("OP_GTE",    yytext); }
"&&"    { print_token("OP_AND",    yytext); }
"||"    { print_token("OP_OR",     yytext); }

 /* ── 3. Keywords (before identifiers) ───────────────────── */

"let"       { print_token("KW_LET",      yytext); }
"const"     { print_token("KW_CONST",    yytext); }
"if"        { print_token("KW_IF",       yytext); }
"else"      { print_token("KW_ELSE",     yytext); }
"while"     { print_token("KW_WHILE",    yytext); }
"true"      { print_token("KW_TRUE",     yytext); }
"false"     { print_token("KW_FALSE",    yytext); }

 /* ── 4. Type Keywords ────────────────────────────────────── */

"number"    { print_token("TYPE_NUMBER",  yytext); }
"string"    { print_token("TYPE_STRING",  yytext); }
"boolean"   { print_token("TYPE_BOOLEAN", yytext); }

 /* ── 5. Literals ─────────────────────────────────────────── */

{NUMBER_LIT}    { print_token("NUM_LIT",    yytext); }
{STRING_LIT}    { print_token("STR_LIT",    yytext); }

 /* ── 6. Identifiers ──────────────────────────────────────── */

{ID}            { print_token("IDENTIFIER", yytext); }

 /* ── 7. Single-character Operators ──────────────────────── */

"+"     { print_token("OP_ADD",    yytext); }
"-"     { print_token("OP_SUB",    yytext); }
"*"     { print_token("OP_MUL",    yytext); }
"/"     { print_token("OP_DIV",    yytext); }
"%"     { print_token("OP_MOD",    yytext); }
"!"     { print_token("OP_NOT",    yytext); }
"<"     { print_token("OP_LT",     yytext); }
">"     { print_token("OP_GT",     yytext); }
"="     { print_token("OP_ASSIGN", yytext); }

 /* ── 8. Delimiters & Punctuation ─────────────────────────── */

"("     { print_token("LPAREN",    yytext); }
")"     { print_token("RPAREN",    yytext); }
"{"     { print_token("LBRACE",    yytext); }
"}"     { print_token("RBRACE",    yytext); }
":"     { print_token("COLON",     yytext); }
";"     { print_token("SEMICOLON", yytext); }

 /* ── 9. Lexical Errors ────────────────────────────────────── */

.   {
        printf("%-5d  *** LEXICAL ERROR ***       Unexpected character: '%s'\n",
               line_num, yytext);
        error_count++;
    }

%%

/* ── main ─────────────────────────────────────────────────── */
int main(int argc, char *argv[]) {

    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
            return 1;
        }
        yyin = f;
    }

    printf("=============================================================\n");
    printf("        Minimal TypeScript Lexer  --  Token Stream\n");
    printf("=============================================================\n");
    printf("%-5s  %-20s  %s\n", "LINE", "TOKEN TYPE", "LEXEME");
    printf("-------------------------------------------------------------\n");

    yylex();

    printf("=============================================================\n");
    printf("  Total tokens  : %d\n", token_count);
    printf("  Lexical errors: %d\n", error_count);
    printf("=============================================================\n");

    if (argc > 1) fclose(yyin);
    return (error_count > 0) ? 1 : 0;
}
