// convert.s — temperature conversion arithmetic

.include "macros.inc"

.section __TEXT, __text, regular, pure_instructions
.align 2

.global convert

.set ABS_ZERO_C,        273          // absolute zero is -273 C (rounded)
.set ABS_ZERO_F,        459          // absolute zero is -459 F (rounded)
.set C_TO_K_OFFSET,     273

// F <-> K without rounding through Celsius: K = (F * 100 + 45967) / 180
.set FK_OFFSET,         45967
.set F_TO_K_MUL,        100
.set FK_DIV,            180
.set K_TO_F_MUL,        180
.set K_TO_F_DIV,        100

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
