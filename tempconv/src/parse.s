// parse.s — argument parsing and flag lookup

.section __TEXT, __text, regular, pure_instructions
.align 2

.global parse_temperature, find_flag

.set MAX_DIGITS,        10           // maximum digits accepted in a temperature
.set MAX_MAGNITUDE,     1000000000   // maximum absolute value accepted

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
