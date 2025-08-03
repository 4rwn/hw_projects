    # My solution to https://leetcode.com/problems/count-number-of-maximum-bitwise-or-subsets
    
    lw x2, 0(x0)            # x2 = n        = nums.length

    li x3, 0                # x3 = i        = 0
    li x4, 0                # x4 = max      = 0
max_loop:
    slli x5, x3, 2          # address offset of element i
    addi x3, x3, 1          # i++
    lw x1, 4(x5)            # x1 = num      = nums[i]
    or x4, x4, x1           # max |= num
    blt x3, x2, max_loop    # repeat if i < n

    li x1, 0                # x1 = result   = 0
    li x3, 0                # i = 0
    li x5, 1
    sll x5, x5, x2          # x5 = 2^n
outer_loop:
    bge x3, x5, outer_done  # done if i >= 2^n
    li x6, 0                # x6 = set      = 0
    li x7, 0                # x7 = j        = 0
inner_loop:
    bge x7, x2, inner_done  # done if j >= n
    srl x8, x3, x7          # x8 = i >> j
    slli x9, x7, 2          # address offset of element j
    addi x7, x7, 1          # j++
    andi x8, x8, 1          # x8 &= 1
    beq x8, x0, inner_loop  # skip if x8 == 0
    lw x8, 4(x9)            # x8 = nums[j]
    or x6, x6, x8           # set |= nums[j]
    j inner_loop
inner_done:
    addi x3, x3, 1          # i++
    bne x6, x4, outer_loop  # skip if set != max
    addi x1, x1, 1          # result++
    j outer_loop
outer_done:
    ecall
    nop
    nop
    nop
