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
        \\ bl   main
        \\2: wfe
        \\ b 2b
    );
}

export fn main() void {
    kernel.kernel_main();
}
