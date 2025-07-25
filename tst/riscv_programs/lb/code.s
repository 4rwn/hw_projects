# Auto-generated by ChatGPT
.section .text
.global _start
_start:

    # Setup base registers
    li x31, 0         # base for addr 0
    li x30, 1         # base for addr 1
    li x29, 2         # base for addr 2
    li x28, 3         # base for addr 3
    li x27, 10
    li x26, 20
    li x25, 1023
    li x24, -10       # offset = +10 → addr 0
    li x23, 1024
    li x22, 2048

    # Basic loads
    lb x1, 0(x31)     # → 0x00
    lb x2, 0(x30)     # → 0x7F
    lb x3, 0(x29)     # → 0x80 → -128
    lb x4, 0(x28)     # → 0xFF → -1
    lb x5, 0(x27)     # → 0x55
    lb x6, 0(x26)     # → 0xAB → -85
    lb x7, 0(x25)     # → 0x11

    # Offset addressing
    lb x8, 10(x24)    # -10 + 10 = 0 → 0x00

    # Register overlap
    li x9, 1
    lb x9, 1(x9)      # → addr 2 → 0x80 → -128

    # Zero register base
    lb x10, 3(x0)     # → addr 3 → 0xFF → -1

    # x0 as destination (ignored)
    lb x0, 2(x0)      # → addr 2 → 0x80 → discarded

    # Extreme immediates
    lb x11, 1023(x0)      # → addr 1023 → 0xDD
    lb x12, -1(x23)       # → 1024 - 1 → 1023 → 0xDD
    lb x13, -2048(x22)    # → 2048 - 2048 = 0 → 0xEE

    # End
    ecall
