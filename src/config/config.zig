const std = @import("std");

pub const Architecture = enum {
    aarch64,
};

pub const Bootloader = enum {
    android,
};

pub const Runner = enum {
    fastboot,
};

pub const BoardTarget = struct {
    arch: Architecture,
    boot: Bootloader,
    run: Runner,
};

pub const Board = struct {
    target: BoardTarget,
};
