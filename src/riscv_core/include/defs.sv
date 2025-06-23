`ifndef DEFS_SV
`define DEFS_SV

typedef enum logic [2:0] { R, I, S, B, U, J, NO_TYPE } instr_format_t;

typedef enum logic [3:0] {
    ADD, // 0
    SUB, // 1
    XOR, // 2
    OR, // 3
    AND, // 4
    SLL, // 5
    SRL, // 6
    SRA, // 7
    LT, // 8
    LTU, // 9
    EQ, // a
    NEQ, // b
    GE, // c
    GEU, // d
    NO_OP // e
} op_t;

`endif
