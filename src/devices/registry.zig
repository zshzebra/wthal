const std = @import("std");

pub const AndroidImage = struct {
    header_version: u8,
    partition_size: u64,
    pagesize: u32,
    cmdline: []const u8,
};

pub const Boot = union(enum) {
    android: AndroidImage,
};

pub const Runner = enum {
    fastboot,
};

pub const DeviceTarget = struct {
    target_query: std.Target.Query,
    boot: Boot,
    run: Runner,
};

pub const Device = struct {
    device_target: DeviceTarget,
};

pub const Devices = enum {
    flame,
};

pub fn getDevice(device: Devices) Device {
    return switch (device) {
        .flame => @import("flame/flame.zig").device,
    };
}
