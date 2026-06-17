const std = @import("std");
const Feature = std.Target.aarch64.Feature;
const registry = @import("../registry.zig");

pub const device: registry.Device = .{
    .device_target = .{
        .target_query = blk: {
            var q: std.Target.Query = .{
                .cpu_arch = .aarch64,
                .os_tag = .freestanding,
                .abi = .none,
            };
            q.cpu_features_add.addFeature(@intFromEnum(Feature.strict_align));
            q.cpu_features_sub.addFeature(@intFromEnum(Feature.neon));
            q.cpu_features_sub.addFeature(@intFromEnum(Feature.fp_armv8));
            break :blk q;
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
