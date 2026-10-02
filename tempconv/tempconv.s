// tempconv.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

.macro round_away_from_zero
    // after sdiv x0, x2, x1
    // x1 is positive (denominator)
    // x2 is clobbered (numerator)
    // x3 is the remainder
    // x4 and x5 are available scratch registers
    // x0 is the result
    msub    x3, x0, x1, x2        // get the remainder so we can round
    eor     x2, x2, x1            // if signs of numerator and denominator are
    cmp     x2, #0                // different, then the result is negative
    mov     x4, #-1               // set up for rounding away from zero
    mov     x5, #1
    csel    x4, x4, x5, lt
    cmp     x3, #0
    cneg    x3, x3, lt            // absolute value of remainder
    lsl     x3, x3, #1            // double the remainder
    cmp     x3, x1                // if |r| * 2 >= d, then adjust for rounding
    csel    x4, x4, xzr, hs       // unsigned comparison
    add     x0, x0, x4            // round away from zero
.endm

_main:
    stp     x29, x30, [sp, #-16]! // prologue
    mov     x29, sp
    stp     x19, x20, [sp, #-16]! // x19 = return code, x20 = *argv
    sub     sp, sp, #32           // allocate space for int to ASCII conversion

    cmp     x0, #3                // verify exactly two arguments provided
    bne     .display_usage

    mov     x20, x1               // preserve argv pointer
    ldr     x1, [x1, #8]          // argv[1]

    // Check if first argument is a temperature or a flag
    ldrb    w2, [x1]
    cmp     w2, #'-'
    bne     .first_arg_is_temperature
    ldrb    w2, [x1, #1]
    cmp     w2, #'-'
    bne     .first_arg_is_temperature

    ldr     x11, [x20, #16]       // temperature is second argument
    mov     x12, x1               // flag is first argument
    b       .parse_temperature

.first_arg_is_temperature:
    mov     x11, x1               // temperature is first argument
    ldr     x12, [x20, #16]       // flag is second argument

.parse_temperature:
    mov     x1, x11
    ldrb    w2, [x1]              // check for negative sign
    cmp     w2, #'-'
    cinc    x1, x1, eq            // skip negative sign if present
    cset    w3, eq                // set negative flag

    mov     x0, #0                // result of converting string to integer
    mov     x4, #0                // argument index
    mov     x10, #10              // base 10 (both input here and output later)

.next_temp_byte:
    ldrb    w2, [x1, x4]          // read next byte
    cbz     w2, .check_negative   // more temperature bytes?
    add     x4, x4, #1            // advance pointer

    sub     w2, w2, #'0'          // convert ASCII to digit
    cmp     w2, #9                // check if valid digit
    bhi     .display_usage        // unsigned: character was not '0'..'9'

    madd    x0, x0, x10, x2       // result = result * 10 + digit
    b       .next_temp_byte

.check_negative:
    cmp     w3, #1                // check if negative flag is set
    cneg    x0, x0, eq            // negate if negative

    // Validate flag argument
    mov     x1, x12
    adrp    x3, conversion_flags@PAGE
    add     x3, x3, conversion_flags@PAGEOFF
    mov     x4, #0                // conversion flag index

.next_flag:
    ldr     x5, [x3, x4, lsl #3]  // get current flag pointer
    cbz     x5, .display_usage    // conversion flag not found
    add     x4, x4, #1            // advance flag index for next iteration
    mov     x6, #0                // reset flag argument index

.next_flag_byte:
    ldrb    w2, [x1, x6]          // get next input flag byte
    cbz     w2, .check_flag_found // end of input flag?
    ldrb    w7, [x5, x6]          // get next candidate flag byte
    cbz     w7, .display_usage    // invalid: all flags are the same length
    cmp     w2, w7
    bne     .next_flag
    add     x6, x6, #1
    b       .next_flag_byte

.check_flag_found:
    ldrb    w7, [x5, x6]          // make sure flag argument is not too long
    cbnz    w7, .display_usage    // invalid: all flags are the same length

    // Pick conversion based on known flag letter positions
    ldrb    w6, [x5, #2]          // source unit
    ldrb    w7, [x5, #7]          // destination unit
    mov     w8, #0xDF             // uppercase mask
    and     w6, w6, w8            // convert source to uppercase
    and     w7, w7, w8            // convert destination to uppercase

    // Write input temperature to output buffer
    adrp    x9, output_buffer@PAGE
    add     x9, x9, output_buffer@PAGEOFF

.next_temp_copy_byte:
    ldrb    w2, [x11], #1         // source
    strb    w2, [x9], #1          // destination
    cbnz    w2, .next_temp_copy_byte

    mov     w2, #' '
    sub     x9, x9, #1            // backup to overwrite null terminator
    strb    w2, [x9], #1          // write space

    strb    w6, [x9], #1          // write source temperature unit
    mov     w2, #' '
    strb    w2, [x9], #1          // write space
    mov     w2, #'-'
    strb    w2, [x9], #1          // write arrow to buffer
    mov     w2, #'>'
    strb    w2, [x9], #1
    mov     w2, #' '
    strb    w2, [x9], #1          // write space

    cmp     w6, #'C'              // determine source temperature unit
    beq     .convert_from_celsius
    cmp     w6, #'F'
    beq     .convert_from_fahrenheit
    cmp     w6, #'K'
    beq     .convert_from_kelvin
    b       .display_usage

.convert_from_celsius:
    cmp     w7, #'F'
    beq     .convert_from_celsius_to_fahrenheit
    sub     x0, x0, #273          // convert Celsius to Kelvin
    cmp     x0, #-273             // invalid if below absolute zero
    blt     .invalid_temp
    b       .write_conversion

.convert_from_celsius_to_fahrenheit:
    mov     x1, #9
    mul     x2, x0, x1
    mov     x1, #5
    sdiv    x0, x2, x1

    round_away_from_zero

    add     x0, x0, #32
    cmp     x0, #-459
    blt     .invalid_temp
    b       .write_conversion

.convert_from_fahrenheit:
    sub     x0, x0, #32           // convert to Celsius
    mov     x1, #5
    mul     x2, x0, x1
    mov     x1, #9
    sdiv    x0, x2, x1

    round_away_from_zero

    cmp     x0, #-273             // invalid if below absolute zero
    blt     .invalid_temp
    cmp     w7, #'C'              // check if destination is Celsius
    beq     .write_conversion
    add     x0, x0, #273          // convert to Kelvin
    b       .write_conversion

.convert_from_kelvin:
    cmp     x0, #0                // invalid if below absolute zero
    blt     .invalid_temp
    add     x0, x0, #273          // convert Kelvin to Celsius
    cmp     w7, #'C'
    beq     .write_conversion

    mov     x1, #9                // convert to Fahrenheit
    mul     x0, x0, x1
    mov     x1, #5
    sdiv    x0, x0, x1
    add     x0, x0, #32           // already checked for invalid temp
    b       .write_conversion

.write_conversion:
    cmp     x0, #0
    bge     .positive_temp
    mov     w2, #'-'
    strb    w2, [x9], #1
    neg     x0, x0

.positive_temp:
    mov     x1, #0                // digit index

.next_digit:
    udiv    x2, x0, x10           // convert conversion to ASCII on the stack
    msub    x3, x2, x10, x0
    add     x3, x3, #'0'          // convert remainder to ASCII
    strb    w3, [sp, x1]
    add     x1, x1, #1
    mov     x0, x2                // remaining digits in conversion result
    cbnz    x2, .next_digit

.next_digit_copy:
    sub     x1, x1, #1            // rewindinding the stack, write the
    ldrb    w2, [sp, x1]          // conversion result to the output buffer
    strb    w2, [x9], #1
    cbnz    x1, .next_digit_copy

    mov     w2, #' '
    strb    w2, [x9], #1          // write space
    strb    w7, [x9], #1          // write destination unit

    // Write the buffer to stdout
    mov     x0, #1                // stdout
    adrp    x1, output_buffer@PAGE
    add     x1, x1, output_buffer@PAGEOFF
    sub     x2, x9, x1            // calculate buffer length (current - start)
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x19, #0               // success
    b       .exit

.invalid_temp:
    mov     x0, #1                // stdout
    adrp    x1, invalid_msg@PAGE  // buffer address
    add     x1, x1, invalid_msg@PAGEOFF
    mov     x2, #invalid_msg_len  // byte count
    mov     x16, #4               // macOS syscall: write
    svc     #0x80

    mov     x19, #1               // failure
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

    add     sp, sp, #32           // free allocated stack space
    ldp     x19, x20, [sp], #16   // epilogue
    ldp     x29, x30, [sp], #16

    mov     x16, #1               // macOS syscall: exit
    svc     #0x80

.section __TEXT, __cstring, cstring_literals

// Code is currently assuming all flags are the same size and pattern
c_to_f: .asciz "--c-to-f"
f_to_c: .asciz "--f-to-c"
k_to_c: .asciz "--k-to-c"
c_to_k: .asciz "--c-to-k"
k_to_f: .asciz "--k-to-f"
f_to_k: .asciz "--f-to-k"

.section __DATA, __data
.p2align 3 // 8-byte alignment for string (pointer) array

conversion_flags:
    .quad c_to_f
    .quad f_to_c
    .quad k_to_c
    .quad c_to_k
    .quad k_to_f
    .quad f_to_k
    .quad 0

.section __TEXT, __const

invalid_msg:
    .ascii "Temperature below absolute zero.\n"
    .set invalid_msg_len, . - invalid_msg

usage:
    .ascii "Usage: tempconv <temperature> <conversion-flag>\n\n"
    .ascii "   --c-to-f    Convert Celsius to Fahrenheit\n"
    .ascii "   --f-to-c    Convert Fahrenheit to Celsius\n"
    .ascii "   --k-to-c    Convert Kelvin to Celsius\n"
    .ascii "   --c-to-k    Convert Celsius to Kelvin\n"
    .ascii "   --k-to-f    Convert Kelvin to Fahrenheit\n"
    .ascii "   --f-to-k    Convert Fahrenheit to Kelvin\n"
    .set usage_len, . - usage

newline:
    .ascii "\n"
    .set newline_len, . - newline

.section __DATA, __bss
.align 4

output_buffer:
    .space 64
