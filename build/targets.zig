const std = @import("std");

pub const target = struct {
    name: []const u8,
    query: std.Target.Query,
    entry: []const u8,
};
