    lw x1, 0(x0)                # load size
    addi x1, x1, -1             # need to stop one before end
    addi x3, x0, 1              # not done

outer:
    beq x3, x0, done            # if done -> exit
    addi x2, x0, 0              # i = 0
    addi x3, x0, 0              # done

inner:
    bge x2, x1, outer           # if i == size -> inner loop done

    slli x4, x2, 2              # address offset of element i
    lw x5, 4(x4)                # load element i
    lw x6, 8(x4)                # load element i+1

    addi x2, x2, 1              # i++

    blt x6, x5, swap
    jal x0, inner

swap:
    addi x3, x0, 1              # not done
    sw x6, 4(x4)                # swap values
    sw x5, 8(x4)

    jal x0, inner

done:
    jal x0, done
