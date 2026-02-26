// TypeScript program with LEXICAL ERRORS
// CS F365 - Phase 1 Error Testing

let x: number = 10;

// ERROR 1: '@' is not a valid character in our language
let y: number = x @ 5;

// ERROR 2: '#' is not a valid character
const flag: boolean = #true;

// ERROR 3: Unterminated string (handled as series of chars + error on quote logic)
// let s: string = "hello;   <- no closing quote, will consume till end

// ERROR 4: '$' is not valid
let $amount: number = 100;

// ERROR 5: backtick not supported (template literals not in our CFG)
let msg: string = `hello`;

// Valid code mixed in to show lexer continues after errors
let z: number = 42;
while (z > 0) {
    z = z - 1;
}
