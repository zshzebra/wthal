const std = @import("std");

// TODO: Some real payload
pub fn kernel_main() void {
    const qemu_serial: *u8 = @ptrFromInt(0x900_0000);
    qemu_serial.* = 'H';
}
