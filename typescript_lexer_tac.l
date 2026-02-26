%{
/*
 * Lexer for Minimal TypeScript — TAC build version
 * CS F365 - Compiler Construction - Phase 2
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typescript_tac.tab.h"   /* token codes from TAC parser */
%}

%option noyywrap yylineno

/* ── Named Definitions ───────────────────────────────────────── */
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

 /* ── Whitespace & Comments ───────────────────────────────────── */
{WHITESPACE}    { /* skip */ }
{NEWLINE}       { /* skip — yylineno auto-incremented */ }
{SL_COMMENT}    { /* skip */ }
{ML_COMMENT}    { /* skip — yylineno auto-incremented */ }

 /* ── Multi-character Operators ───────────────────────────────── */
"=="    { return OP_EQ;  }
"!="    { return OP_NEQ; }
"<="    { return OP_LTE; }
">="    { return OP_GTE; }
"&&"    { return OP_AND; }
"||"    { return OP_OR;  }

 /* ── Keywords ────────────────────────────────────────────────── */
"let"       { return KW_LET;      }
"const"     { return KW_CONST;    }
"if"        { return KW_IF;       }
"else"      { return KW_ELSE;     }
"while"     { return KW_WHILE;    }
"true"      { return KW_TRUE;     }
"false"     { return KW_FALSE;    }

 /* ── Type Keywords ───────────────────────────────────────────── */
"number"    { return TYPE_NUMBER;  }
"string"    { return TYPE_STRING;  }
"boolean"   { return TYPE_BOOLEAN; }

 /* ── Literals ─────────────────────────────────────────────────── */
{NUMBER_LIT}    { yylval.sval = strdup(yytext); return NUM_LIT;    }
{STRING_LIT}    { yylval.sval = strdup(yytext); return STR_LIT;    }

 /* ── Identifiers ──────────────────────────────────────────────── */
{ID}            { yylval.sval = strdup(yytext); return IDENTIFIER; }

 /* ── Single-character Operators ──────────────────────────────── */
"+"     { return OP_ADD;    }
"-"     { return OP_SUB;    }
"*"     { return OP_MUL;    }
"/"     { return OP_DIV;    }
"%"     { return OP_MOD;    }
"!"     { return OP_NOT;    }
"<"     { return OP_LT;     }
">"     { return OP_GT;     }
"="     { return OP_ASSIGN; }

 /* ── Delimiters ───────────────────────────────────────────────── */
"("     { return LPAREN;    }
")"     { return RPAREN;    }
"{"     { return LBRACE;    }
"}"     { return RBRACE;    }
":"     { return COLON;     }
";"     { return SEMICOLON; }

 /* ── Lexical Errors ───────────────────────────────────────────── */
.   {
        fprintf(stderr, "[LEXICAL ERROR] Line %d: Unexpected character '%s'\n",
                yylineno, yytext);
    }

%%
