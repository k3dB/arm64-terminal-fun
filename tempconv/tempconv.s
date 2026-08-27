// tempconv.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

_main:
    stp     x29, x30, [sp, #-16]! // prologue
    mov     x29, sp
    stp     x19, x20, [sp, #-16]! // x19 = return code, x20 = *argv

    cmp     x0, #3                // verify exactly two arguments provided
    bne     .display_usage

    mov     x20, x1               // preserve argv pointer
    ldr     x1, [x1, #8]          // argv[1]

// TODO: Implement temperature conversion argument parsing
    mov     x0, #0                // convert argv[1] to integer
    mov     x3, #10               // base 10
    mov     x4, #0                // digit counter for argv[1] length

.next_byte:
    ldrb    w2, [x1], #1          // read next byte, advance pointer
    cbz     w2, .validate         // more bytes to process?

    sub     w2, w2, #'0'          // convert ASCII to digit
    cmp     w2, #9                // check if valid digit
    bhi     .display_usage        // unsigned: character was not '0'..'9'

    madd    x0, x0, x3, x2        // result = result * 10 + digit
    add     x4, x4, #1            // increment digit counter
    b       .next_byte

.validate:
    cbz     x0, .display_usage    // if year is 0, display usage
    lsr     x1, x0, #16           // check if year is within 16-bit range
    cbnz    x1, .display_usage

// TODO: Implement leap year calculation logic
    and     x1, x0, #3            // year divisible by 4?
    cbnz    x1, .not_a_leap_year

    mov     x2, #100              // Is the year divisible by 100?
    sdiv    x1, x0, x2            // x = y / 100       | integer division
    msub    x2, x1, x2, x0        // r = y - (x * 100) | get the remainder
    cbnz    x2, .is_a_leap_year   // if not, it is a leap year

    and     x2, x1, #3            // Is year / 100 divisible by 4 (by 400)?
    cbnz    x2, .not_a_leap_year  // if not, it is not a leap year

.is_a_leap_year:
    mov     x5, #1
    b       .print_year

.not_a_leap_year:
    mov     x5, #0
    b       .print_year

.print_year:
    mov     x0, #1                // stdout
    ldr     x1, [x20, #8]         // argv[1]
    mov     x2, x4                // length of argv[1]
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    cbz     x5, .print_not_leap_year
    adrp    x1, is_a_leap_year@PAGE
    add     x1, x1, is_a_leap_year@PAGEOFF
    mov     x2, #is_a_leap_year_len
    b       .print_result

.print_not_leap_year:
    adrp    x1, not_a_leap_year@PAGE
    add     x1, x1, not_a_leap_year@PAGEOFF
    mov     x2, #not_a_leap_year_len

.print_result:
    mov     x0, #1                // stdout
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x19, #0               // success
    b       .exit

// ^^^ End of changes left to make

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

usage:
    .ascii "Usage: tempconv <temperature> <conversion-flag>\n\n"
    .ascii "   --c-to-f    Convert Celsius to Fahrenheit\n"
    .ascii "   --f-to-c    Convert Fahrenheit to Celsius\n"
    .set usage_len, . - usage

newline:
    .ascii "\n"
    .set newline_len, . - newline
