const std = @import("std");

pub const FdtHeader = extern struct {
    magic: u32 = 0xd00dfeed,
    total_size: u32,
    off_dt_struct: u32,
    off_dt_strings: u32,
    off_mem_rsvmap: u32,
    version: u32,
    last_comp_version: u32,
    boot_cpuid_phys: u32,
    size_dt_strings: u32,
    size_dt_struct: u32,
};

pub fn ParseHeader(ptr: *[@sizeOf(FdtHeader)]u8) FdtHeader {
    var header = std.mem.bytesToValue(FdtHeader, ptr.*);
    std.mem.byteSwapAllFields(FdtHeader, &header);
    return header;
}
