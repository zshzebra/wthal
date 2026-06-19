const kernel = @import("kernel");
const devicetree = @import("DeviceTree");

export fn _start() linksection(".text.boot") callconv(.naked) noreturn {
    asm volatile (
    // The android bootloader jumps here for init
        \\ b 1f
        // Header
        \\ .long 0
        \\ .quad 0x80000
        \\ .quad _image_size
        \\ .quad 0x0a
        \\ .quad 0, 0, 0
        \\ .ascii "ARM\x64"
        \\ .long 0
        // Our actual init
        \\1:
        // Set stack pointer
        \\ adrp x1, __stack_top
        \\ add  x1, x1, :lo12:__stack_top
        \\ mov  sp, x1
        // Store bss start address in x9, end in x10
        \\ adrp x9, __bss_start
        \\ add x9, x9, :lo12:__bss_start
        \\ adrp x10, __bss_end
        \\ add x10, x10, :lo12:__bss_end
        \\2:
        // Branch to 3 if x9 is higher than or equal to x10
        \\ cmp x9,x10
        \\ b.hs 3f
        // Store 64-bit 0 register to address x9 and loop back to the comparison
        \\ str xzr, [x9], #8
        \\ b 2b
        \\3:
        // Store image top in x11, rela start in x12 and rela end in x13
        \\ adrp x11, _image_top
        \\ add  x11, x11, :lo12:_image_top
        \\ adrp x12, __rela_start
        \\ add  x12, x12, :lo12:__rela_start
        \\ adrp x13, __rela_end
        \\ add  x13, x13, :lo12:__rela_end
        \\5:
        // Branch to main if x12 is rela end
        \\ cmp x12, x13
        \\ b.hs 6f
        // Read the elf rela, x14 is the offset, x16 is addend
        \\ ldr x14, [x12]
        \\ ldr x15, [x12, #8]
        \\ ldr x16, [x12, #16]
        // Advance x12 to the next symbol
        \\ add x12, x12, #24
        // Check if the relocation type is RELATIVE
        \\ and x17, x15, #0xffffffff
        \\ cmp x17, #0x403
        // If not RELATIVE process the next symbol
        \\ b.ne 5b
        // The target address
        \\ add x14, x14, x11
        // Compute and store the relocated value
        \\ add x16, x16, x11
        \\ str x16, [x14]
        // Loop for the next symbol
        \\ b 5b
        \\6:
        \\ bl   main
        // Main returned for some reason, halt
        \\4: wfe
        \\ b 4b
    );
}

export fn main(dt_addr: [*]const u8) void {
    kernel.kernel_main(dt_addr);
}
