ENTRY(_start)
SECTIONS
{
    .text.boot : { KEEP(*(.text.boot)) }
    .text : { *(.text .text.*) }
    .rodata : { *(.rodata .rodata.*) }
    .eh_frame_hdr : { *(.eh_frame_hdr) }
    .eh_frame     : { *(.eh_frame) }
    .data : { *(.data data.*) }
    .bss : { *(.bss bss.*) }
    . = . + 0x4000;
    __stack_top = .;
    _image_size = .;
}
