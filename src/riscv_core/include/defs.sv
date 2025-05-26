`ifndef DEFS_SV
`define DEFS_SV

typedef enum logic [2:0] { R, I, S, B, U, J, NO_TYPE } instr_format_t;

typedef enum logic [4:0] {
    ADD, SUB, // Simple arithmetic
    MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU, // Complex arithmetic
    XOR, OR, AND, // Logic
    SLL, SRL, SRA, // Shifts
    LT, LTU, EQ, NEQ, GE, GEU, // Comparison
    NO_OP // Invalid or unknown
} op_t;

`endif
