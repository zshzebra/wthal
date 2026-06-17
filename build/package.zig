const std = @import("std");

pub const Output = struct {
    file: std.Build.LazyPath,
    ext: []const u8,
};

pub const android = @import("android.zig").package;
