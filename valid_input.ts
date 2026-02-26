// Valid TypeScript test program
// CS F365 - Phase 1 Testing

let x: number = 10;
let y: number = 3.14;
const name: string = "Alice";
let flag: boolean = true;

// Arithmetic & assignment
x = x + y * 2;
x = (x - 1) % 5;

// Relational and logical expressions
let result: boolean = (x >= 5) && (flag || false);

// If-else statement
if (x > 0) {
    let msg: string = "positive";
    flag = true;
} else {
    flag = false;
}

// Nested if-else
if (x == 10) {
    x = x + 1;
} else if (x != 0) {
    x = x - 1;
} else {
    x = 0;
}

// While loop
let i: number = 0;
while (i < 10) {
    i = i + 1;
}

/* Multi-line comment:
   This tests block comment skipping */
let z: number = i % 3;
