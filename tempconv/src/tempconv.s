// tempconv.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
.set STDOUT,            1
.set SYS_EXIT,          1
.set SYS_WRITE,         4

.set MAX_DIGITS,        10           // maximum digits accepted in a temperature
.set MAX_MAGNITUDE,     1000000000   // maximum absolute value accepted
.set EXIT_SUCCESS,      0
.set EXIT_FAILURE,      1

.set ABS_ZERO_C,        273          // absolute zero is -273 C (rounded)
.set ABS_ZERO_F,        459          // absolute zero is -459 F (rounded)
.set C_TO_K_OFFSET,     273

// F <-> K without rounding through Celsius: K = (F * 100 + 45967) / 180
.set FK_OFFSET,         45967
.set F_TO_K_MUL,        100
.set FK_DIV,            180
.set K_TO_F_MUL,        180
.set K_TO_F_DIV,        100

// Flag strings are all the same shape: "--X-to-Y"
.set FLAG_SRC_OFFSET,   2
.set FLAG_DST_OFFSET,   7

// ---------------------------------------------------------------------------
// Macros
// ---------------------------------------------------------------------------
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

// Write a static buffer to stdout. Clobbers x0-x2, x16.
.macro write_const buf, len
    adrp    x1, \buf\()@PAGE
    add     x1, x1, \buf\()@PAGEOFF
    mov     x2, #\len
    bl      write_stdout
.endm

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
exit_code   .req x19                // process exit status
temp_str    .req x20                // temperature argument string
flag_str    .req x21                // conversion flag argument string
temp_val    .req x22                // parsed temperature
src_unit    .req w23                // source unit letter ('C', 'F', 'K')
dst_unit    .req w24                // destination unit letter
out_ptr     .req x25                // current write position in output_buffer

_main:
    stp     x29, x30, [sp, #-16]! // prologue
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    cmp     x0, #3                // verify exactly two arguments provided
    bne     .display_usage

    ldr     temp_str, [x1, #8]    // assume argv[1] is the temperature
    ldr     flag_str, [x1, #16]   // and argv[2] is the flag

    // Check if first argument is a flag (starts with "--") rather than a
    // temperature
    ldrb    w2, [temp_str]
    cmp     w2, #'-'
    bne     .args_ordered
    ldrb    w2, [temp_str, #1]
    cmp     w2, #'-'
    bne     .args_ordered
    mov     x2, temp_str          // swap: flag first, temperature second
    mov     temp_str, flag_str
    mov     flag_str, x2

.args_ordered:
    mov     x0, temp_str
    bl      parse_temperature
    cbnz    x1, .display_usage
    mov     temp_val, x0

    mov     x0, flag_str
    bl      find_flag
    cbz     x0, .display_usage

    ldrb    src_unit, [x0, #FLAG_SRC_OFFSET]
    ldrb    dst_unit, [x0, #FLAG_DST_OFFSET]
    mov     w8, #0xDF             // uppercase mask
    and     src_unit, src_unit, w8
    and     dst_unit, dst_unit, w8

    // Write "<input> <src> -> " to the output buffer
    adrp    x0, output_buffer@PAGE
    add     x0, x0, output_buffer@PAGEOFF
    mov     x1, temp_str
    mov     w2, src_unit
    bl      write_prefix
    mov     out_ptr, x0

    mov     x0, temp_val
    mov     w1, src_unit
    mov     w2, dst_unit
    bl      convert
    cbnz    x1, .invalid_temp

    mov     x1, out_ptr
    bl      format_int            // write the converted value

    mov     w2, #' '
    strb    w2, [x0], #1          // write space
    strb    dst_unit, [x0], #1    // write destination unit

    adrp    x1, output_buffer@PAGE
    add     x1, x1, output_buffer@PAGEOFF
    sub     x2, x0, x1            // calculate buffer length (current - start)
    bl      write_stdout

    mov     exit_code, #EXIT_SUCCESS
    b       .exit

.invalid_temp:
    write_const invalid_msg, invalid_msg_len
    mov     exit_code, #EXIT_FAILURE
    b       .exit

.display_usage:
    write_const usage, usage_len
    mov     exit_code, #EXIT_FAILURE

.exit:
    write_const newline, newline_len

    mov     x0, exit_code         // return success/failure

    ldp     x25, x26, [sp], #16   // epilogue
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16

    mov     x16, #SYS_EXIT
    svc     #0x80

.unreq exit_code
.unreq temp_str
.unreq flag_str
.unreq temp_val
.unreq src_unit
.unreq dst_unit
.unreq out_ptr

// ---------------------------------------------------------------------------
// write_stdout
//   in:      x1 = buffer address, x2 = byte count
//   clobbers x0, x16
// ---------------------------------------------------------------------------
write_stdout:
    mov     x0, #STDOUT
    mov     x16, #SYS_WRITE
    svc     #0x80
    ret

// ---------------------------------------------------------------------------
// parse_temperature
//   in:     x0 = NUL-terminated string: optional '-', then 1..MAX_DIGITS digits
//   out:    x0 = signed value, x1 = 0 on success or 1 if invalid
//   clobbers x2-x5
// ---------------------------------------------------------------------------
parse_temperature:
    ldrb    w2, [x0]              // check first temperature byte
    cbz     w2, .parse_invalid    // empty string
    cmp     w2, #'-'              // check if negative
    cinc    x1, x0, eq            // skip negative sign if present
    cset    w3, eq                // set negative flag

    mov     x0, #0                // result of converting string to integer
    mov     x4, #0                // digit count / index
    mov     x5, #10               // base 10

.parse_next_byte:
    ldrb    w2, [x1, x4]          // read next byte
    cbz     w2, .parse_check_value // more temperature bytes?
    add     x4, x4, #1            // advance pointer

    sub     w2, w2, #'0'          // convert ASCII to digit
    cmp     w2, #9                // check if valid digit
    bhi     .parse_invalid        // unsigned: character was not '0'..'9'
    cmp     x4, #MAX_DIGITS       // limit input to the maximum number of digits
    bhi     .parse_invalid

    madd    x0, x0, x5, x2        // result = result * 10 + digit
    b       .parse_next_byte

.parse_check_value:
    cbz     x4, .parse_invalid    // no digits parsed
    ldr     x2, =MAX_MAGNITUDE    // check the magnitude against the maximum
    cmp     x0, x2
    bgt     .parse_invalid
    cmp     w3, #1                // check if negative flag is set
    cneg    x0, x0, eq            // negate if negative
    mov     x1, #0
    ret

.parse_invalid:
    mov     x1, #1
    ret

// ---------------------------------------------------------------------------
// find_flag
//   in:      x0 = NUL-terminated flag argument
//   out:     x0 = matching entry in conversion_flags, or 0 if not found
//   clobbers x1-x7
// ---------------------------------------------------------------------------
find_flag:
    mov     x1, x0
    adrp    x3, conversion_flags@PAGE
    add     x3, x3, conversion_flags@PAGEOFF
    mov     x4, #0                // conversion flag index

.find_next_flag:
    ldr     x5, [x3, x4, lsl #3]  // get current flag pointer
    cbz     x5, .find_not_found   // conversion flag not found
    add     x4, x4, #1            // advance flag index for next iteration
    mov     x6, #0                // reset flag argument index

.find_next_flag_byte:
    ldrb    w2, [x1, x6]          // get next input flag byte
    cbz     w2, .find_end_of_input // end of input flag?
    ldrb    w7, [x5, x6]          // get next candidate flag byte
    cbz     w7, .find_not_found   // invalid: all flags are the same length
    cmp     w2, w7
    bne     .find_next_flag
    add     x6, x6, #1
    b       .find_next_flag_byte

.find_end_of_input:
    ldrb    w7, [x5, x6]          // make sure flag argument is not too long
    cbnz    w7, .find_not_found   // invalid: all flags are the same length
    mov     x0, x5
    ret

.find_not_found:
    mov     x0, #0
    ret

// ---------------------------------------------------------------------------
// write_prefix: writes "<temperature> <src> -> " to the output buffer
//   in:      x0 = output pointer, x1 = temperature string, w2 = source unit
//   out:     x0 = output pointer after the written text
//   clobbers x1, x3
// ---------------------------------------------------------------------------
write_prefix:
.prefix_copy_byte:
    ldrb    w3, [x1], #1          // source
    cbz     w3, .prefix_write_unit
    strb    w3, [x0], #1          // destination
    b       .prefix_copy_byte

.prefix_write_unit:
    mov     w3, #' '
    strb    w3, [x0], #1          // write space
    strb    w2, [x0], #1          // write source temperature unit
    strb    w3, [x0], #1          // write space
    mov     w3, #'-'
    strb    w3, [x0], #1          // write arrow to buffer
    mov     w3, #'>'
    strb    w3, [x0], #1
    mov     w3, #' '
    strb    w3, [x0], #1          // write space
    ret

// ---------------------------------------------------------------------------
// convert
//   in:      x0 = temperature, w1 = source unit, w2 = destination unit
//            (units are uppercase 'C', 'F' or 'K'; source != destination)
//   out:     x0 = converted temperature
//            x1 = 0 on success, 1 if the input is below absolute zero
//   clobbers x1-x6
// ---------------------------------------------------------------------------
convert:
    mov     w6, w2                // destination unit (x1 is used as a scratch)
    cmp     w1, #'C'
    beq     .convert_from_celsius
    cmp     w1, #'F'
    beq     .convert_from_fahrenheit

.convert_from_kelvin:
    cmp     x0, #0                // invalid if below absolute zero
    blt     .convert_below_zero
    cmp     w6, #'C'
    bne     .convert_from_kelvin_to_fahrenheit
    sub     x0, x0, #C_TO_K_OFFSET // convert Kelvin to Celsius
    b       .convert_ok

.convert_from_kelvin_to_fahrenheit:
    mov     x1, #K_TO_F_MUL       // K * 180
    mul     x0, x0, x1
    mov     x1, #FK_OFFSET        // subtract 45967
    sub     x2, x0, x1
    mov     x1, #K_TO_F_DIV       // divide by 100
    sdiv    x0, x2, x1
    round_away_from_zero
    b       .convert_ok

.convert_from_celsius:
    cmp     x0, #-ABS_ZERO_C      // invalid if below absolute zero
    blt     .convert_below_zero
    cmp     w6, #'F'
    beq     .convert_from_celsius_to_fahrenheit
    add     x0, x0, #C_TO_K_OFFSET // convert Celsius to Kelvin
    b       .convert_ok

.convert_from_celsius_to_fahrenheit:
    mov     x1, #9
    mul     x2, x0, x1
    mov     x1, #5
    sdiv    x0, x2, x1
    round_away_from_zero
    add     x0, x0, #32
    b       .convert_ok

.convert_from_fahrenheit:
    cmp     x0, #-ABS_ZERO_F      // invalid if below absolute zero
    blt     .convert_below_zero
    cmp     w6, #'C'
    bne     .convert_from_fahrenheit_to_kelvin

    sub     x0, x0, #32           // convert to Celsius
    mov     x1, #5
    mul     x2, x0, x1
    mov     x1, #9
    sdiv    x0, x2, x1
    round_away_from_zero
    b       .convert_ok

.convert_from_fahrenheit_to_kelvin:
    mov     x1, #F_TO_K_MUL       // F * 100 + 45967
    mov     x2, #FK_OFFSET
    madd    x2, x0, x1, x2
    mov     x1, #FK_DIV           // divide by 180
    sdiv    x0, x2, x1
    round_away_from_zero

.convert_ok:
    mov     x1, #0
    ret

.convert_below_zero:
    mov     x1, #1
    ret

// ---------------------------------------------------------------------------
// format_int: writes a signed integer as decimal ASCII
//   in:      x0 = value, x1 = output pointer
//   out:     x0 = output pointer after the written digits
//   clobbers x1-x5
// ---------------------------------------------------------------------------
format_int:
    sub     sp, sp, #32           // allocate space for int to ASCII conversion
    cmp     x0, #0
    bge     .format_positive
    mov     w2, #'-'
    strb    w2, [x1], #1
    neg     x0, x0

.format_positive:
    mov     x3, #10               // base 10
    mov     x4, #0                // digit index

.format_next_digit:
    udiv    x2, x0, x3            // convert conversion to ASCII on the stack
    msub    x5, x2, x3, x0
    add     x5, x5, #'0'          // convert remainder to ASCII
    strb    w5, [sp, x4]
    add     x4, x4, #1
    mov     x0, x2                // remaining digits in conversion result
    cbnz    x2, .format_next_digit

.format_next_digit_copy:
    sub     x4, x4, #1            // rewinding the stack, write the conversion
    ldrb    w2, [sp, x4]          // result to the output buffer
    strb    w2, [x1], #1
    cbnz    x4, .format_next_digit_copy

    mov     x0, x1
    add     sp, sp, #32           // free allocated stack space
    ret

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
    .ascii "   --f-to-k    Convert Fahrenheit to Kelvin\n\n"
    .ascii "   Maximum temperature: 1,000,000,000\n"
    .ascii "   Use only digits and optional negative sign. No commas or other symbols.\n"
    .set usage_len, . - usage

newline:
    .ascii "\n"
    .set newline_len, . - newline

.section __DATA, __bss
.align 4

output_buffer:
    .space 64
