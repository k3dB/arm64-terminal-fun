// isprime.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

_main:
    stp     x29, x30, [sp, #-16]! // prologue
    stp     x19, x20, [sp, #-16]! // x19 = return code, x20 = *argv

    cmp     x0, #2                // verify exactly one argument provided
    bne     .display_usage

    mov     x20, x1               // preserve argv pointer
    ldr     x1, [x1, #8]          // argv[1]

    mov     x0, #0                // convert argv[1] to integer
    mov     x3, #10               // base 10
    mov     x4, #0                // digit counter for argv[1] length
    mov     x5, #0                // count leading zeros

.next_byte:
    ldrb    w2, [x1], #1          // read next byte, advance pointer
    cbz     w2, .validate         // more bytes to process?

    sub     w2, w2, #'0'          // convert ASCII to digit
    cmp     w2, #9                // check if valid digit
    bhi     .display_usage        // unsigned: character was not '0'..'9'

    mov     x7, x0
    mul     x0, x7, x3            // low 64 bits of n * 10
    umulh   x6, x7, x3            // high 64 bits of n * 10
    cbnz    x6, .display_usage    // multiplication overflowed

    adds    x0, x0, x2            // add digit and set carry
    bcs     .display_usage        // addition overflowed

    cmp     x0, #0
    cinc    x5, x5, eq            // count leading zeros
    cinc    x4, x4, ne            // count non-leading-zero digits
    b       .next_byte

.validate:
    cmp     x4, #0                // edge case: input was all zeros
    csel    x4, x5, x4, eq        // if there were no non-leading-zero digits,
    csel    x5, xzr, x5, eq       // swap leading zero count with digit count
    cbz     x4, .display_usage    // no digits provided

    cmp     x0, #2
    blt     .not_prime            // 0 and 1 are not prime
    beq     .is_prime             // 2 is prime

    and     x1, x0, #1            // number even or odd?
    cbz     x1, .not_prime        // even numbers > 2 are not prime

// Uses binary search version of the integer square root algorithm.
    mov     x2, x0           // preserve original input for comparison
    mov     x0, xzr          // left side (and final result)
    add     x1, x2, #1       // right side

.next_root:
    sub     x3, x1, #1       // one less than right side
    cmp     x3, x0           // loop until left side is one less than right side
    beq     .found_root      // did we find the integer square root?
    add     x3, x1, x0       // if not, continue binary search by...
    lsr     x3, x3, #1       // ...finding the next median
    mul     x6, x3, x3       // square the current median
    cmp     x6, x2           // compare with original input
    csel    x0, x3, x0, le   // if too small or matched, bring left up to median
    csel    x1, x3, x1, gt   // if too big, bring right side down to median
    b       .next_root

// At this point:
// x0 contains the integer square root
// x2 contains the original input
// x4 contains the number of non-leading-zero digits
// x5 contains the number of leading zeros

.found_root:
    mov     x1, #3                // start with 3

.next_odd:
    cmp     x1, x0                // check if current number is greater than square root
    bgt     .is_prime             // if so, number is prime
    udiv    x3, x2, x1            // divide original number by current odd value
    msub    x6, x3, x1, x2        // get remainder
    cbz     x6, .not_prime        // if remainder is 0, number is not prime
    add     x1, x1, #2            // increment by 2 to get next odd number
    b       .next_odd

.is_prime:
    mov     x6, #1
    b       .print_number

.not_prime:
    mov     x6, #0

.print_number:
    mov     x0, #1                // stdout
    ldr     x1, [x20, #8]         // argv[1]
    add     x1, x1, x5            // skip leading zeros
    mov     x2, x4                // number of non-leading-zero digits
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    cbz     x6, .print_not_prime
    adrp    x1, is_prime@PAGE
    add     x1, x1, is_prime@PAGEOFF
    mov     x2, #is_prime_len
    b       .print_result

.print_not_prime:
    adrp    x1, not_prime@PAGE
    add     x1, x1, not_prime@PAGEOFF
    mov     x2, #not_prime_len

.print_result:
    mov     x0, #1                // stdout
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x19, #0               // success
    b       .exit

.display_usage:
    mov     x0, #1                // stdout
    adrp    x1, usage@PAGE        // buffer address
    add     x1, x1, usage@PAGEOFF
    mov     x2, #usage_len        // byte count
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x19, #1               // failure

.exit:
    // Write newline before exiting
    mov     x0, #1                // stdout
    adrp    x1, newline@PAGE      // buffer address
    add     x1, x1, newline@PAGEOFF
    mov     x2, #newline_len      // byte count
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x0, x19               // return success/failure

    ldp     x19, x20, [sp], #16   // epilogue
    ldp     x29, x30, [sp], #16

    mov     x16, #1               // macOS syscall: exit
    svc     #0x80

.section __TEXT, __const

is_prime:
    .ascii " is a prime number."
    .set is_prime_len, . - is_prime

not_prime:
    .ascii " is not a prime number."
    .set not_prime_len, . - not_prime

usage:
    .ascii "Usage: isprime <number>\n    <number> must be between 0 and"
    .ascii " 18446744073709551615 (64-bit unsigned integer)"
    .set usage_len, . - usage

newline:
    .ascii "\n"
    .set newline_len, . - newline
