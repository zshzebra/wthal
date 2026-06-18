const kernel = @import("kernel");
const devicetree = @import("DeviceTree");

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
        \\ adrp x11, _image_top
        \\ add  x11, x11, :lo12:_image_top
        \\ adrp x12, __rela_start
        \\ add  x12, x12, :lo12:__rela_start
        \\ adrp x13, __rela_end
        \\ add  x13, x13, :lo12:__rela_end
        \\5:
        \\ cmp x12, x13
        \\ b.hs 6f
        \\ ldr x14, [x12]
        \\ ldr x15, [x12, #8]
        \\ ldr x16, [x12, #16]
        \\ add x12, x12, #24
        \\ and x17, x15, #0xffffffff
        \\ cmp x17, #0x403
        \\ b.ne 5b
        \\ add x14, x14, x11
        \\ add x16, x16, x11
        \\ str x16, [x14]
        \\ b 5b
        \\6:
        \\ bl   main
        \\4: wfe
        \\ b 4b
    );
}

export fn main(dt_addr: [*]const u8) void {
    kernel.kernel_main(dt_addr);
}
