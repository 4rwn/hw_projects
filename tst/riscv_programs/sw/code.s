    .text
    .globl _start
_start:
    # Setup registers (x31 down to x18)
    li x31, 100           # Test1 base address
    li x30, 0x0F1E2D3C    # Test1 source value
    li x29, 252           # Test2 base address
    li x28, 0x4B5A6978    # Test2 source value
    li x27, 500           # Test3 base address
    li x26, 0xA1B2C3D4    # Test3 source value
    li x25, 500           # Test4 base address
    li x24, 0xE5F6D7C8    # Test4 source value
    li x23, 2048          # Test5 base address (min immediate)
    li x22, 0x12345678    # Test5 source value
    li x21, -1027         # Test6 base address (max immediate)
    li x20, 0xCAFEBABE    # Test6 source value
    li x19, 300           # Test7 base address (x0 as rs2)
    li x18, 0xDEADBEEF    # Test8 source value (x0 as rs1)

    # Tests
    sw x30,    0(x31)     # MEM[100..103]  = 3c 2d 1e 0f
    sw x28,   -4(x29)     # MEM[248..251]  = 78 69 5a 4b
    sw x26,     4(x27)    # MEM[504..507]  = d4 c3 b2 a1
    sw x24,    -8(x25)    # MEM[492..495]  = c8 d7 f6 e5
    sw x22,-2048(x23)     # MEM[0..3]      = 78 56 34 12
    sw x20, 2047(x21)     # MEM[1020..1023]= be ba fe ca
    sw x0,      8(x19)    # MEM[308..311]  = 00 00 00 00
    sw x18,    400(x0)    # MEM[400..403]  = ef be ad de
    sw x0,     500(x0)    # MEM[500..503]  = 00 00 00 00

    ecall
