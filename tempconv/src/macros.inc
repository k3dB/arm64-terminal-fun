// macros.inc — shared macros

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
