    .text
    .globl _start
_start:
    # Setup registers (x31 down to x18)
    li x31, 100           # Test1 base address
    li x30, 0x000000A5    # Test1 source value (0xA5)
    li x29, 254           # Test2 base address
    li x28, 0x0000005A    # Test2 source value (0x5A)
    li x27, 500           # Test3 base address
    li x26, 0x000000FF    # Test3 source value (0xFF)
    li x25, 500           # Test4 base address
    li x24, 0x00000000    # Test4 source value (0x00)
    li x23, -1024         # Test5 base address
    li x22, 0x12345678    # Test5 source value (0x78)
    li x21, 2048          # Test6 base address
    li x20, 0x87654321    # Test6 source value (0x21)
    li x19, 123           # Test7 base address (x0-source)
    li x18, 0x000000D4    # Test8 source value (x0-base)

    # Tests
    sb x30,    0(x31)    # MEM[100] = 0xA5
    sb x28,   -1(x29)    # MEM[253] = 0x5A
    sb x26,    1(x27)    # MEM[501] = 0xFF
    sb x24,   -2(x25)    # MEM[498] = 0x00
    sb x22, 2047(x23)    # MEM[1023] = 0x78
    sb x20,-2048(x21)    # MEM[0] = 0x21
    sb x0,     2(x19)    # MEM[125] = 0x00
    sb x18,  300(x0)     # MEM[300] = 0xD4
    sb x0,     5(x0)     # MEM[5] = 0x00

    ecall
    nop
    nop
    nop
