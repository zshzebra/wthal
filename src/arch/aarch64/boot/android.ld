ENTRY(_start)
SECTIONS
{
    _image_top = .;
    .text.boot : { KEEP(*(.text.boot)) }
    .text : { *(.text .text.*) }
    .rodata : { *(.rodata .rodata.*) }
    .eh_frame_hdr : { *(.eh_frame_hdr) }
    .eh_frame     : { *(.eh_frame) }
    .data : { *(.data data.*) }
    . = ALIGN(8); __bss_start = .;
    .bss : { *(.bss .bss.*) *(COMMON) }
    . = ALIGN(8); __bss_end = .;
    . = . + 0x4000;
    __stack_top = .;
    _image_size = . - _image_top;
}
