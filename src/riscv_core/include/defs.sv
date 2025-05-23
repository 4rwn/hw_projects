`ifndef DEFS_SV
`define DEFS_SV

typedef enum { R, I, S, B, U, J, NO_TYPE } instr_format_t;

typedef enum {
    ADD, SUB, // Arithmetic
    XOR, OR, AND, // Logic
    SLL, SRL, SRA, // Shifts
    LT, LTU, EQ, NEQ, GE, GEU, // Comparison
    NO_OP // Invalid or unknown
} alu_op_t;

`endif
