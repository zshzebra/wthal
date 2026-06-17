const registry = @import("../registry.zig");

pub const device: registry.Device = .{
    .device_target = .{
        .target_query = .{
            .cpu_arch = .aarch64,
            .os_tag = .freestanding,
            .abi = .none,
        },
        .boot = .{ .android = .{
            .header_version = 2,
            .partition_size = 0x4000000,
            .cmdline = "",
            .pagesize = 4096,
        } },
        .run = .fastboot,
    },
};
