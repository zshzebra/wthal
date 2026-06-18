const std = @import("std");
const devicetree = @import("DeviceTree");
const fb = @import("drivers/fb/fb.zig");

var should_be_zero: u32 = 0;

// TODO: Some real payload
pub fn kernel_main(dt_addr: [*]const u8) void {
    var framebuffer: fb.Framebuffer(.rgb) = .{
        .buffer = @as([*]volatile u32, @ptrFromInt(0x9c400000))[0 .. 2280 * 1080 * 4],
        .mode = .{
            .width = 1080,
            .height = 2280,
            .pitch = 1080 * 4,
            .bpp = 32,
            .color_format = .{
                .red_mask_size = 8,
                .red_mask_shift = 16,
                .green_mask_size = 8,
                .green_mask_shift = 8,
                .blue_mask_size = 8,
                .blue_mask_shift = 0,
            },
        },
    };
    framebuffer.clear(0x1e1e2e);

    if (@as(*volatile u32, &should_be_zero).* != 0) {}

    const device_tree = devicetree.fromPtr(@alignCast(dt_addr)) catch {
        framebuffer.clear(0xf38ba8);
        while (true) {
            asm volatile ("wfi");
        }
    };

    _ = device_tree;
    framebuffer.clear(0xa6e3a1);
}
