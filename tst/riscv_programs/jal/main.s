    .text
    .globl _start
_start:
    # Sentinel values for skipped‐LI checks
    li   x2,  0x22222222    # Test1 skip
    li   x5,  0x55555555    # Test2 skip #1
    li   x6,  0x66666666    # Test2 skip #2
    li   x9,  0x99999999    # Test4 skip
    li   x11, 0xFFFFFFFF    # Test3 skip

    # Test1: forward jump over 1 instruction; rd = x1
    jal  x1, .+8
    addi   x2, x0, 0        # skipped → x2 stays 0x22222222
    li   x3, 0x33333333     # executed → x3 = 0x33333333

    # Test2: forward jump over 2 instructions; rd = x4
    jal  x4, .+12
    addi   x5, x0, 0        # skipped → x5 stays 0x55555555
    addi   x6, x0, 0        # skipped → x6 stays 0x66666666
    li   x7, 0x77777777     # executed → x7 = 0x77777777

    # Test3: negative‐immediate jump with additional skipped LIs
    jal  x0, skip3          # unconditionally skip to skip3
forward3:
    li   x12, 0x12121212    # executed
    jal  x0, after3         # forward jump to after3
skip3:
    li   x13, 0x13131313    # executed
    jal  x8, forward3       # negative jump back to forward3JAL
    li   x11, 0x11111111    # skipped
after3:
    li   x10, 0xAAAAAAAA    # marker: executed after negative test

    # Test4: rd = x0 (link discarded), skip 1
    jal  x0, .+8
    addi   x9, x0, 0        # skipped → x9 stays 0x99999999
    li   x11, 0xEEEEEEEE    # executed → x11 = 0xEEEEEEEE

    ecall
    nop
    nop
    nop
