    .text
    .globl _start
_start:
    # Setup registers (x31 down to x18)
    li x31, 100           # Test1 base address
    li x30, 0x0000A5A5    # Test1 source value (0xA5A5)
    li x29, 254           # Test2 base address
    li x28, 0x00005A5A    # Test2 source value (0x5A5A)
    li x27, 500           # Test3 base address
    li x26, 0x0000FF00    # Test3 source value (0xFF00)
    li x25, 500           # Test4 base address
    li x24, 0x00000000    # Test4 source value (0x0000)
    li x23, -1024         # Test5 base address
    li x22, 0x00001234    # Test5 source value (0x1234)
    li x21, 2048          # Test6 base address
    li x20, 0x00008765    # Test6 source value (0x8765)
    li x19, 123           # Test7 base address (x0-source)
    li x18, 0x0000D4D4    # Test8 source value (x0-base)

    # Tests
    sh x30,    0(x31)    # MEM[100]=0xA5, MEM[101]=0xA5
    sh x28,   -1(x29)    # MEM[253]=0x5A, MEM[254]=0x5A
    sh x26,    1(x27)    # MEM[501]=0x00, MEM[502]=0xFF
    sh x24,   -2(x25)    # MEM[498]=0x00, MEM[499]=0x00
    sh x22,  2046(x23)   # MEM[1022]=0x34, MEM[1023]=0x12
    sh x20,-2048(x21)    # MEM[0]=0x65, MEM[1]=0x87
    sh x0,      2(x19)   # MEM[125]=0x00, MEM[126]=0x00
    sh x18,  300(x0)     # MEM[300]=0xD4, MEM[301]=0xD4
    sh x0,      5(x0)    # MEM[5]=0x00, MEM[6]=0x00

    ecall
    nop
    nop
    nop
