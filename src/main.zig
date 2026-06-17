const std = @import("std");

// TODO: Some real payload
pub fn kernel_main() void {
    const fb: [*]volatile u32 = @ptrFromInt(0x9c400000);
    @memset(fb[0 .. 1080 * 2280], 0xffff0000);
}
