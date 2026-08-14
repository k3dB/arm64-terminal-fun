// leapyear.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions

.global _main
.align 2

_main:
    stp     x29, x30, [sp, #-16]! // prologue
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    cmp     x0, #2
    bne     .display_usage

    mov     x4, x1                // preserve argv
    ldr     x1, [x4, #8]          // argv[1]
    mov     x2, #-1               // length counter

.next_arg_byte:
    add     x2, x2, #1
    ldrb    w3, [x1, x2]          // load next byte
    cbnz    w3, .next_arg_byte    // more bytes?

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

usage:
    .ascii "Usage: leapyear <year>"
    .set usage_len, . - usage

newline:
    .ascii "\n"
    .set newline_len, . - newline
