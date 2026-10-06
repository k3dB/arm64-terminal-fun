// output.s — output buffer building and writing

.section __TEXT, __text, regular, pure_instructions
.align 2

.global write_stdout, write_prefix, format_int, output_buffer

.set STDOUT,            1
.set SYS_WRITE,         4

// ---------------------------------------------------------------------------
// write_stdout
//   in:    x1 = buffer address, x2 = byte count
// ---------------------------------------------------------------------------
write_stdout:
    mov     x0, #STDOUT
    mov     x16, #SYS_WRITE
    svc     #0x80
    ret

// ---------------------------------------------------------------------------
// write_prefix: writes "<temperature> <src> -> " to the output buffer
//   in:    x0 = output pointer, x1 = temperature string, w2 = source unit
//   out:   x0 = output pointer after the written text
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
// format_int: writes a signed integer as decimal ASCII
//   in:    x0 = value, x1 = output pointer
//   out:   x0 = output pointer after the written digits
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

.section __DATA, __bss
.align 4

output_buffer:
    .space 64
