// main.s — program entry: argument handling and orchestration

.include "macros.inc"

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

.set SYS_EXIT,          1
.set EXIT_SUCCESS,      0
.set EXIT_FAILURE,      1

// Flag strings are all the same shape: "--X-to-Y"
.set FLAG_SRC_OFFSET,   2
.set FLAG_DST_OFFSET,   7

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
exit_code   .req x19              // process exit status
temp_str    .req x20              // temperature argument string
flag_str    .req x21              // conversion flag argument string
temp_val    .req x22              // parsed temperature
src_unit    .req w23              // source unit letter ('C', 'F', 'K')
dst_unit    .req w24              // destination unit letter
out_ptr     .req x25              // current write position in output_buffer

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
