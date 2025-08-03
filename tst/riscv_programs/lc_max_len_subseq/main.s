    # My solution to https://leetcode.com/problems/find-the-maximum-length-of-valid-subsequence-i
    
    lw x2, 0(x0)        # x2 = n        = nums.length
    li x3, 0            # x3 = evenCnt  = 0
    li x4, 0            # x4 = oddCnt   = 0
    li x5, 0            # x5 = chainCnt = 0

    # x6 = chainCur = 1 - (nums[0] % 2)
    lw x6, 4(x0)
    andi x6, x6, 1
    xori x6, x6, 1

    li x7, 0            # x7 = i        = 0
loop:
    bge x7, x2, end_loop # exit loop if i >= n

    slli x8, x7, 2      # memory offset of nums[i] from array start
    lw x9, 4(x8)        # x9 = nums[i]
    andi x9, x9, 1      # x9 = nums[i] % 2
    addi x7, x7, 1      # i++
    beq x9, x0, even

    # nums[i] is odd
    addi x4, x4, 1     # oddCnt++
    beq x6, x0, advance_chain
    j loop

    # nums[i] is even
even: 
    addi x3, x3, 1     # evenCnt++
    bne x6, x0, advance_chain
    j loop

advance_chain:
    xori x6, x6, 1      # chainCur = 1 - chainCur
    addi x5, x5, 1      # chainCnt++
    j loop

end_loop:
    bgt x3, x4, max1    # x1 = Max(evenCnt, oddCnt)
    addi x1, x4, 0
    j max2
max1:
    addi x1, x3, 0
max2:
    bgt x1, x5, done    # x1 = Max(x1, chainCnt)
    addi x1, x5, 0

done:
    ecall
    nop
    nop
    nop
