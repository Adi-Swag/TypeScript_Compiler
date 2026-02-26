%{
/*
 * Three Address Code Generator for Minimal TypeScript
 * CS F365 - Compiler Construction - Phase 2
 * Tool: Bison
 *
 * Build:  see Makefile_tac
 * Run:    ./ts_tac < input.ts
 *     OR  ./ts_tac input.ts
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int   yylex();
extern int   yylineno;
extern FILE *yyin;

/* ── Error reporting ─────────────────────────────────────────── */
void yyerror(const char *msg) {
    fprintf(stderr, "\n[SYNTAX ERROR] Line %d: %s\n", yylineno, msg);
}

int syntax_errors = 0;

/* ── Temporary variable counter ──────────────────────────────── */
static int temp_count  = 0;
static int label_count = 0;

/* Generate a new unique temporary: t1, t2, t3, ... */
char *new_temp() {
    char *buf = malloc(16);
    sprintf(buf, "t%d", ++temp_count);
    return buf;
}

/* Generate a new unique label: L1, L2, L3, ... */
char *new_label() {
    char *buf = malloc(16);
    sprintf(buf, "L%d", ++label_count);
    return buf;
}

/* Emit a TAC instruction */
void emit(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    printf("    ");          /* indent for readability */
    vprintf(fmt, args);
    printf("\n");
    va_end(args);
}

/* Emit a label (no indent) */
void emit_label(const char *label) {
    printf("%s:\n", label);
}
%}

/* ── Value type ──────────────────────────────────────────────── */
%union {
    char *sval;   /* holds: identifier name, literal value,
                             or generated temporary name       */
}

/* ── Token Declarations ──────────────────────────────────────── */

%token <sval> IDENTIFIER
%token <sval> NUM_LIT
%token <sval> STR_LIT

%token KW_LET
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_WHILE
%token KW_TRUE
%token KW_FALSE

%token TYPE_NUMBER
%token TYPE_STRING
%token TYPE_BOOLEAN

%token OP_EQ OP_NEQ OP_LTE OP_GTE OP_LT OP_GT
%token OP_AND OP_OR OP_NOT
%token OP_ADD OP_SUB OP_MUL OP_DIV OP_MOD
%token OP_ASSIGN

%token LPAREN RPAREN LBRACE RBRACE COLON SEMICOLON

/* ── Types for non-terminals that return values ──────────────── */
%type <sval> Expr Primary IfHeader ElseJump WhileStart WhileCond

/* ── Precedence & Associativity (lowest → highest) ───────────── */
%left  OP_OR
%left  OP_AND
%left  OP_EQ  OP_NEQ
%left  OP_LT  OP_GT  OP_LTE  OP_GTE
%left  OP_ADD OP_SUB
%left  OP_MUL OP_DIV OP_MOD
%right OP_NOT UMINUS

%start Program

%%

/* ================================================================
   GRAMMAR RULES WITH TAC GENERATION
   ================================================================ */

Program
    : StmtList
        {
            printf("\n");
            printf("=============================================================\n");
            printf("  TAC generation complete. \n");
            printf("=============================================================\n");
        }
    ;

StmtList
    : StmtList Stmt
    | /* empty */
    ;

Stmt
    : VarDecl
    | AssignStmt
    | IfStmt
    | WhileStmt
    | Block
    | error SEMICOLON   { syntax_errors++; yyerrok; }
    | error RBRACE      { syntax_errors++; yyerrok; }
    ;

Block
    : LBRACE StmtList RBRACE
    ;

/* ── Variable Declaration ────────────────────────────────────── */

VarDecl
    : VarKeyword IDENTIFIER COLON Type OP_ASSIGN Expr SEMICOLON
        {
            /* e.g.  let x : number = t3;  →  x = t3  */
            emit("%s = %s", $2, $6);
            free($2); free($6);
        }
    | VarKeyword IDENTIFIER COLON Type SEMICOLON
        {
            /* Declaration without initializer — no TAC needed */
            emit("/* %s declared (no init) */", $2);
            free($2);
        }
    ;

VarKeyword
    : KW_LET
    | KW_CONST
    ;

Type
    : TYPE_NUMBER
    | TYPE_STRING
    | TYPE_BOOLEAN
    ;

/* ── Assignment Statement ────────────────────────────────────── */

AssignStmt
    : IDENTIFIER OP_ASSIGN Expr SEMICOLON
        {
            emit("%s = %s", $1, $3);
            free($1); free($3);
        }
    ;

/* ── If Statement ────────────────────────────────────────────── */
/*
 * TAC pattern for if (Expr) Block:
 *     <Expr TAC>
 *     if_false t goto L_end
 *     <Block TAC>
 *  L_end:
 *
 * TAC pattern for if (Expr) Block else Block:
 *     <Expr TAC>
 *     if_false t goto L_else
 *     <Block TAC>
 *     goto L_end
 *  L_else:
 *     <else TAC>
 *  L_end:
 *
 * IfHeader is a typed non-terminal that emits the conditional
 * jump and returns the false-label as its value.
 */

IfHeader
    : KW_IF LPAREN Expr RPAREN
        {
            char *l_false = new_label();
            emit("if_false %s goto %s", $3, l_false);
            free($3);
            $$ = l_false;
        }
    ;

IfStmt
    : IfHeader Block
        {
            /* if only */
            emit_label($1);
            free($1);
        }
    | IfHeader Block ElseJump KW_ELSE Block
        {
            /*
             * $1 = L_else (from IfHeader)
             * $3 = L_end  (from ElseJump mid-rule)
             */
            emit_label($3);
            free($1); free($3);
        }
    | IfHeader Block ElseJump KW_ELSE IfStmt
        {
            emit_label($3);
            free($1); free($3);
        }
    ;

/* ElseJump: emits "goto L_end" and "L_else:" between if-body and else */
ElseJump
    : /* empty */
        {
            char *l_end = new_label();
            /* $0 is IfHeader's label (L_else) — use $<sval>0 */
            emit("goto %s", l_end);
            emit_label($<sval>0);   /* L_else: */
            $$ = l_end;
        }
    ;

/* ── While Statement ─────────────────────────────────────────── */
/*
 * TAC pattern:
 *  L_start:
 *     <Expr TAC>
 *     if_false t goto L_end
 *     <Block TAC>
 *     goto L_start
 *  L_end:
 */

WhileStart
    : KW_WHILE
        {
            char *l_start = new_label();
            emit_label(l_start);
            $$ = l_start;
        }
    ;

WhileStmt
    : WhileStart LPAREN Expr WhileCond RPAREN Block
        {
            emit("goto %s", $1);     /* loop back to L_start */
            emit_label($4);          /* L_end: */
            free($1); free($3); free($4);
        }
    ;

WhileCond
    : /* empty, fires after Expr is reduced */
        {
            char *l_end = new_label();
            emit("if_false %s goto %s", $<sval>0, l_end);
            $$ = l_end;
        }
    ;

/* ── Expressions ─────────────────────────────────────────────── */
/*
 * Each binary expression:
 *   1. Allocates a new temporary
 *   2. Emits:  t_new = left op right
 *   3. Returns t_new as $$
 */

Expr
    : Expr OP_OR  Expr  { char *t = new_temp(); emit("%s = %s || %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_AND Expr  { char *t = new_temp(); emit("%s = %s && %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_EQ  Expr  { char *t = new_temp(); emit("%s = %s == %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_NEQ Expr  { char *t = new_temp(); emit("%s = %s != %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_LT  Expr  { char *t = new_temp(); emit("%s = %s < %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_GT  Expr  { char *t = new_temp(); emit("%s = %s > %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_LTE Expr  { char *t = new_temp(); emit("%s = %s <= %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_GTE Expr  { char *t = new_temp(); emit("%s = %s >= %s", t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_ADD Expr  { char *t = new_temp(); emit("%s = %s + %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_SUB Expr  { char *t = new_temp(); emit("%s = %s - %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_MUL Expr  { char *t = new_temp(); emit("%s = %s * %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_DIV Expr  { char *t = new_temp(); emit("%s = %s / %s",  t,$1,$3); free($1);free($3); $$=t; }
    | Expr OP_MOD Expr  { char *t = new_temp(); emit("%s = %s %% %s", t,$1,$3); free($1);free($3); $$=t; }
    | OP_NOT Expr
        {
            char *t = new_temp();
            emit("%s = ! %s", t, $2);
            free($2);
            $$ = t;
        }
    | OP_SUB Expr %prec UMINUS
        {
            char *t = new_temp();
            emit("%s = - %s", t, $2);
            free($2);
            $$ = t;
        }
    | Primary  { $$ = $1; }
    ;

/* ── Primary ─────────────────────────────────────────────────── */
/* Primaries just pass their value/name up — no TAC emitted yet  */

Primary
    : IDENTIFIER    { $$ = $1; }
    | NUM_LIT       { $$ = $1; }
    | STR_LIT       { $$ = $1; }
    | KW_TRUE       { $$ = strdup("true");  }
    | KW_FALSE      { $$ = strdup("false"); }
    | LPAREN Expr RPAREN { $$ = $2; }
    ;

%%

/* ── main ─────────────────────────────────────────────────────── */
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
    printf("  Minimal TypeScript — Three Address Code Generator\n");
    printf("=============================================================\n\n");

    yyparse();

    if (syntax_errors > 0)
        fprintf(stderr, "\n  %d syntax error(s) encountered.\n", syntax_errors);

    if (argc > 1) fclose(yyin);
    return (syntax_errors > 0) ? 1 : 0;
}
