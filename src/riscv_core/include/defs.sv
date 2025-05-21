`ifndef DEFS_SV
`define DEFS_SV

typedef enum { R, I, S, B, U, J, NO_TYPE } instr_format_t;

typedef enum {
    ADD, SUB,
    XOR, OR, AND,
    SLL, SRL, SRA,
    LT, LTU, EQ, NEQ, GE, GEU,
    NO_OP
} op_t;

`endif
