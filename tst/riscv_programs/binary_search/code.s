    lw x2, 0(x0)                # search key

    li x3, 0                    # low = 0
    lw x4, 4(x0)                # load size
    addi x4, x4, -1             # high = size-1

loop:
    blt x4, x3, not_found       # if high < low -> not found

    add x5, x3, x4
    srai x5, x5, 1              # mid = low+high / 2

    slli x6, x5, 2              # mid element address offset
    lw x7, 8(x6)                # load mid element

    beq x7, x2, found           # if mid == search key -> found
    blt x7, x2, go_right        # if mid < search key -> search on the right

    addi x4, x5, -1             # otherwise search on the left, high = mid-1
    j loop

go_right:
    addi x3, x5, 1              # low = mid+1
    j loop

found:
    li x1, 1
    j done

not_found:
    li x1, 0

done:
    ecall
