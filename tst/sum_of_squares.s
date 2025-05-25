# Calculate the sum of the first N squares.

    .text
    .globl _start
_start:
    lui   x1, 0x00000        # x1 = 0x0000 (base addr)
    addi  x2, x0, 6          # x2 = N
    addi  x3, x0, 1          # x3 = i = 1
    addi  x4, x0, 0          # x4 = sum = 0

loop:
    addi  x5, x3, 0          # x5 = i (for inner mult)
    addi  x8, x3, 0
    addi  x6, x0, 0          # x6 = result = 0

# multiply x3 * x3 via shift-add (i*i)
mul_loop:
    andi  x7, x5, 1          # if (bit == 1)
    beq   x7, x0, skip_add
    add   x6, x6, x8         # x6 += x8

skip_add:
    slli  x8, x8, 1          # x8 <<= 1
    srli  x5, x5, 1          # x5 >>= 1
    bne   x5, x0, mul_loop   # loop while x5 != 0

    add   x4, x4, x6         # sum += i*i
    addi  x3, x3, 1          # i += 1
    blt   x2, x3, done       # if i > N: break
    jal   x0, loop           # goto loop

done:
    sw    x4, 0(x1)          # store result at 0x1004
hang:
    jal   x0, hang           # infinite loop
