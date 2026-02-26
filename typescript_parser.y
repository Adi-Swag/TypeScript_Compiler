%{
/*
 * Parser for Minimal TypeScript
 * CS F365 - Compiler Construction
 * Tool: Bison
 *
 * Build:  see Makefile
 * Run:    ./ts_compiler < input.ts
 *     OR  ./ts_compiler input.ts
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int  yylex();
extern int  yylineno;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *msg) {
    fprintf(stderr, "\n[SYNTAX ERROR] Line %d: %s\n", yylineno, msg);
}

int syntax_errors = 0;
%}

/* ── Value type ──────────────────────────────────────────────── */
%union {
    int   ival;
    float fval;
    char *sval;
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
   GRAMMAR RULES
   ================================================================ */

Program
    : StmtList
        { printf("\n[OK] Program is syntactically valid.\n"); }
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
    | error SEMICOLON
        { syntax_errors++; yyerrok; }
    | error RBRACE
        { syntax_errors++; yyerrok; }
    ;

Block
    : LBRACE StmtList RBRACE
        { printf("[BLOCK] Block parsed.\n"); }
    ;

/* ── Variable Declaration ────────────────────────────────────── */

VarDecl
    : VarKeyword IDENTIFIER COLON Type OP_ASSIGN Expr SEMICOLON
        { printf("[DECL] '%s' declared with initializer.\n", $2); free($2); }
    | VarKeyword IDENTIFIER COLON Type SEMICOLON
        { printf("[DECL] '%s' declared without initializer.\n", $2); free($2); }
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

/* ── Assignment ──────────────────────────────────────────────── */

AssignStmt
    : IDENTIFIER OP_ASSIGN Expr SEMICOLON
        { printf("[ASSIGN] Assignment to '%s'.\n", $1); free($1); }
    ;

/* ── If Statement ────────────────────────────────────────────── */

IfStmt
    : KW_IF LPAREN Expr RPAREN Block
        { printf("[IF] if statement parsed.\n"); }
    | KW_IF LPAREN Expr RPAREN Block KW_ELSE Block
        { printf("[IF] if-else parsed.\n"); }
    | KW_IF LPAREN Expr RPAREN Block KW_ELSE IfStmt
        { printf("[IF] if-else-if chain parsed.\n"); }
    ;

/* ── While Statement ─────────────────────────────────────────── */

WhileStmt
    : KW_WHILE LPAREN Expr RPAREN Block
        { printf("[WHILE] while loop parsed.\n"); }
    ;

/* ── Expressions ─────────────────────────────────────────────── */

Expr
    : Expr OP_OR  Expr              { printf("[EXPR] OR\n");    }
    | Expr OP_AND Expr              { printf("[EXPR] AND\n");   }
    | Expr OP_EQ  Expr              { printf("[EXPR] ==\n");    }
    | Expr OP_NEQ Expr              { printf("[EXPR] !=\n");    }
    | Expr OP_LT  Expr              { printf("[EXPR] <\n");     }
    | Expr OP_GT  Expr              { printf("[EXPR] >\n");     }
    | Expr OP_LTE Expr              { printf("[EXPR] <=\n");    }
    | Expr OP_GTE Expr              { printf("[EXPR] >=\n");    }
    | Expr OP_ADD Expr              { printf("[EXPR] +\n");     }
    | Expr OP_SUB Expr              { printf("[EXPR] -\n");     }
    | Expr OP_MUL Expr              { printf("[EXPR] *\n");     }
    | Expr OP_DIV Expr              { printf("[EXPR] /\n");     }
    | Expr OP_MOD Expr              { printf("[EXPR] %%\n");    }
    | OP_NOT Expr                   { printf("[EXPR] NOT\n");   }
    | OP_SUB Expr %prec UMINUS      { printf("[EXPR] UMINUS\n");}
    | Primary
    ;

Primary
    : IDENTIFIER    { printf("[PRIMARY] id: %s\n",  $1); free($1); }
    | NUM_LIT       { printf("[PRIMARY] num: %s\n", $1); free($1); }
    | STR_LIT       { printf("[PRIMARY] str: %s\n", $1); free($1); }
    | KW_TRUE       { printf("[PRIMARY] true\n");  }
    | KW_FALSE      { printf("[PRIMARY] false\n"); }
    | LPAREN Expr RPAREN
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
    printf("     Minimal TypeScript Parser  --  Syntax Analysis\n");
    printf("=============================================================\n\n");

    yyparse();

    printf("-------------------------------------------------------------\n");
    if (syntax_errors == 0)
        printf("  Result : SUCCESS — No syntax errors found.\n");
    else
        printf("  Result : FAILED  — %d syntax error(s) found.\n", syntax_errors);
    printf("=============================================================\n");

    if (argc > 1) fclose(yyin);
    return (syntax_errors > 0) ? 1 : 0;
}
