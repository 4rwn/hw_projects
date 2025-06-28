    addi x5, x0, 1
    addi x1, x5, 0
    addi x2, x0, -1
    add x2, x1, x2
    lui x3, 0
    addi x3, x3, 1000
    sw x3, 0(x0)
    lw x4, 0(x0)
    addi x4, x4, -2000
