    addi x1, x0, -87           # search key

    addi x2, x0, 0              # low = 0
    lw x3, 0(x0)                # load size
    addi x3, x3, -1             # high = size-1

loop:
    blt x3, x2, not_found       # if high < low -> not found

    add x4, x2, x3
    srai x4, x4, 1              # mid = low+high / 2

    slli x5, x4, 2              # mid element address offset
    lw x6, 4(x5)                # load mid element

    beq x6, x1, found           # if mid == search key -> found
    blt x6, x1, go_right        # if mid < search key -> search on the right

    addi x3, x4, -1             # otherwise search on the left, high = mid-1
    jal x0, loop

go_right:
    addi x2, x4, 1              # low = mid+1
    jal x0, loop

found:
    addi x7, x0, 1
    jal x0, done

not_found:
    addi x7, x0, 0

done:
    jal x0, done