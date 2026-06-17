const std = @import("std");

pub fn run(b: *std.Build, img: std.Build.LazyPath) *std.Build.Step {
    const cmd = b.addSystemCommand(&.{ "fastboot", "boot" });
    cmd.addFileArg(img);
    return &cmd.step;
}
