`ifndef DEFS_SV
`define DEFS_SV

typedef enum logic [2:0] { R, I, S, B, U, J, NO_TYPE } instr_format_t;

typedef enum logic [3:0] {
    ADD,    // 0
    SUB,    // 1
    XOR,    // 2
    OR,     // 3
    AND,    // 4
    SLL,    // 5
    SRL,    // 6
    SRA,    // 7
    LT,     // 8
    LTU,    // 9
    EQ,     // a
    NEQ,    // b
    GE,     // c
    GEU,    // d
    NO_OP   // e
} alu_op_t;

typedef enum logic [3:0] {
    UNKNOWN,    // 0
    MATH,       // 1
    LOAD,       // 2
    STORE,      // 3
    BRANCH,     // 4
    JAL,        // 5
    JALR,       // 6
    LUI,        // 7
    ENV,        // 8
    NONE        // 9
} instr_type_t;

typedef enum logic [2:0] {
    BYTE,
    HALF,
    WORD,
    BYTE_UNSIGNED,
    HALF_UNSIGNED
} mem_type_t;

`endif
