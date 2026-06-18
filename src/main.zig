const std = @import("std");
const devicetree = @import("DeviceTree");
const framebuffer = @import("drivers/framebuffer/framebuffer.zig");
const fbcon = @import("drivers/fbcon/fbcon.zig");

var should_be_zero: u32 = 0;

// TODO: Some real payload
pub fn kernel_main(dt_addr: [*]const u8) void {
    const width = 1080;
    const height = 2280;
    const pitch = width * @sizeOf(u32);

    var fb: framebuffer.Framebuffer(.rgb) = .{
        .buffer = @as([*]volatile u32, @ptrFromInt(0x9c400000))[0 .. width * height],
        .mode = .{
            .width = width,
            .height = height,
            .pitch = pitch,
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
    fb.clear(0x1e1e2e);

    if (@as(*volatile u32, &should_be_zero).* != 0) {}

    const device_tree = devicetree.fromPtr(@alignCast(dt_addr)) catch {
        fb.clear(0xf38ba8);
        while (true) {
            asm volatile ("wfi");
        }
    };

    _ = device_tree;
    fb.clear(0xa6e3a1);

    const con = fbcon.FbCon(.rgb).init(&fb);
    // TODO: USE
}
