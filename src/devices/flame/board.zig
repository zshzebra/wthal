const config = @import("config");

pub const board: config.Board = .{
    .target = .{ .arch = .aarch64, .boot = .android, .run = .fastboot },
};
