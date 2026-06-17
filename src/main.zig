const std = @import("std");

var should_be_zero: u32 = 0;

// TODO: Some real payload
pub fn kernel_main() void {
    const fb: [*]volatile u32 = @ptrFromInt(0x9c400000);
    @memset(fb[0 .. 1080 * 2280], 0xffa6e3a1);

    if (@as(*volatile u32, &should_be_zero).* != 0) @memset(fb[0 .. 1080 * 2280], 0xffff0000);
}
