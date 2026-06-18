ENTRY(_start)
SECTIONS
{
    . = 0;
    _image_top = .;
    .text.boot : { KEEP(*(.text.boot)) }
    .text : { *(.text .text.*) }
    .rodata : { *(.rodata .rodata.*) }
    .data.rel.ro : { *(.data.rel.ro .data.rel.ro.*) }
    .got : { *(.got) *(.got.plt) }
    .eh_frame_hdr : { *(.eh_frame_hdr) }
    .eh_frame     : { *(.eh_frame) }
    .data : { *(.data .data.*) }
    .rela.dyn : {
        . = ALIGN(8);
        __rela_start = .;
        *(.rela .rela.* .rela_dyn)
        __rela_end = .;
    }
    . = ALIGN(8); __bss_start = .;
    .bss : { *(.bss .bss.*) *(COMMON) }
    . = ALIGN(8); __bss_end = .;
    . = . + 0x4000;
    . = ALIGN(16); __stack_top = .;
    _image_size = . - _image_top;

    /DISCARD/ : { *(.dynsym) *(.dynstr) *(.hash) *(.gnu.hash) *(.dynamic) *(.interp) }
}
