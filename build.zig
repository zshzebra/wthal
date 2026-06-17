const std = @import("std");
const config = @import("src/config/config.zig");

pub fn build(b: *std.Build) void {
    const config_module = b.addModule("config", .{
        .root_source_file = b.path("src/config/config.zig"),
    });

    const boards: []config.Board = undefined;

    const kernel = b.addExecutable(.{
        .name = "wthal",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });
    kernel.root_module.addImport("config", config_module);

    b.installArtifact(kernel);
}
