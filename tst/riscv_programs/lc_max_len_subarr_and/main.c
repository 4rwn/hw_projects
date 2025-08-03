__attribute__((naked, used, noreturn))
void _start(void) {
    asm volatile (
        "lui   sp, %hi(_estack)\n"
        "addi  sp, sp, %lo(_estack)\n"
        "call main\n"
        "mv x1, a0\n"
        "ecall\n"
        "nop\n"
        "nop\n"
        "nop\n"
    );
}

// My solution to https://leetcode.com/problems/longest-subarray-with-maximum-bitwise-and
int numsSize __attribute__((section(".inputs")));
int nums[128] __attribute__((section(".inputs")));
int main() {
    int max = 0;
    int len = 0;
    int result = 0;
    for (int i = 0; i < numsSize; i++) {
        int num = nums[i];
        if (num > max) {
            max = num;
            len = 1;
            result = 0;
        } else if (num == max) {
            len++;
        } else {
            if (len > result) {
                result = len;
            }
            len = 0;
        }
    }
    return len > result ? len : result;
}