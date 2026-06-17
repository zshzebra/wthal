const kernel = @import("kernel");

export fn _start() linksection(".text.boot") callconv(.naked) noreturn {
    asm volatile (
        \\ b 1f
        \\ .long 0
        \\ .quad 0x80000
        \\ .quad _image_size
        \\ .quad 0x0a
        \\ .quad 0, 0, 0
        \\ .ascii "ARM\x64"
        \\ .long 0
        \\1:
        \\ adrp x1, __stack_top
        \\ add  x1, x1, :lo12:__stack_top
        \\ mov  sp, x1
        \\ adrp x9, __bss_start
        \\ add x9, x9, :lo12:__bss_start
        \\ adrp x10, __bss_end
        \\ add x10, x10, :lo12:__bss_end
        \\2:
        \\ cmp x9,x10
        \\ b.hs 3f
        \\ str xzr, [x9], #8
        \\ b 2b
        \\3:
        \\ bl   main
        \\4: wfe
        \\ b 4b
    );
}

export fn main(dt_addr: *const [4]u8) void {
    kernel.kernel_main(dt_addr);
}
