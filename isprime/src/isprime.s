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
    mov     x6, #0                // count leading zeros

.next_byte:
    ldrb    w2, [x1], #1          // read next byte, advance pointer
    cbz     w2, .validate         // more bytes to process?

    sub     w2, w2, #'0'          // convert ASCII to digit
    cmp     w2, #9                // check if valid digit
    bhi     .display_usage        // unsigned: character was not '0'..'9'

    madd    x0, x0, x3, x2        // result = result * 10 + digit
    lsr     x5, x0, #64           // check if still within 64-bit range
    cbnz    x5, .display_usage
    cmp     x0, #0
    cinc    x6, x6, eq            // count leading zeros
    cinc    x4, x4, ne            // count non-leading-zero digits
    b       .next_byte

.validate:
// Test if the number is prime. A number is prime if:
// 1. It is greater than 1
// 2. It has no divisors other than 1 and itself
    cmp     x0, #2
    blt     .not_prime
    beq     .is_prime

    and     x1, x0, #1            // number even?
    cbz     x1, .not_prime

.is_prime:
    mov     x5, #1
    b       .print_number

.not_prime:
    mov     x5, #0
    b       .print_number

.print_number:
    mov     x0, #1                // stdout
    ldr     x1, [x20, #8]         // argv[1]
    add     x1, x1, x6            // skip leading zeros
    mov     x2, x4                // number of non-leading-zero digits
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    cbz     x5, .print_not_prime
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
