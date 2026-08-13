// leapyear.s — ARM64v8 assembly for macOS

.section __TEXT, __text, regular, pure_instructions
.global _main
.align 2

_main:
    // write(1, usage_message, usage_message_length)
    mov     x0, #1              // stdout
    adrp    x1, usage@PAGE      // buffer address
    add     x1, x1, usage@PAGEOFF
    mov     x2, #24             // byte count
    mov     x16, #4             // macOS syscall: write
    svc     #0x80

    // exit(0)
    mov     x0, #0
    mov     x16, #1             // macOS syscall: exit
    svc     #0x80

.section __TEXT, __cstring
usage:
    .asciz "Usage: leapyear <year>\n"
