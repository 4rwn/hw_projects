.section .text
.globl _start

_start:
    addi x1, x0, 0        # x1 = 0
    addi x2, x0, 5        # x2 = 5

    beq  x1, x2, skip1    # not taken → next instr runs
    addi x3, x0, 1        # should execute (x3 = 1)

skip1:
    beq  x2, x2, skip2    # taken → skip next instr
    addi x4, x0, 2        # should be flushed (x4 should stay 0)

skip2:
    bne  x2, x2, skip3    # not taken → next executes
    addi x5, x0, 3        # should execute (x5 = 3)

skip3:
    jal x6, target        # jump to target (x6 = return addr)
    addi x7, x0, 4        # should be flushed

target:
    addi x8, x0, 8        # should execute after jump

    # Test jalr
    addi x9, x0, 0x20
    jalr x0, 0(x9)        # jump to 0x20 (infinite loop)

    nop                   # to align 0x20
    nop
    nop
    nop
    nop
loop:
    jal x0, loop          # infinite loop
