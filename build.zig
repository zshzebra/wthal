const std = @import("std");
const registry = @import("src/devices/registry.zig");
const package = @import("build/package.zig");
const runner = @import("build/runner/runner.zig");

pub fn build(b: *std.Build) error{DeviceMustBeProvided}!void {
    const device_opt = b.option(registry.Devices, "device", "The target device") orelse .flame;
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });

    const kernel_module = b.addModule("kernel", .{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
    });

    const config_module = b.addModule("config", .{
        .root_source_file = b.path("src/devices/registry.zig"),
        .optimize = optimize,
    });

    const device = registry.getDevice(device_opt);

    const arch = device.device_target.target_query.cpu_arch.?;
    const root = b.fmt("src/arch/{s}/boot/{s}.zig", .{
        @tagName(arch),
        @tagName(device.device_target.boot),
    });

    const kernel = b.addExecutable(.{
        .name = "wthal",
        .root_module = b.createModule(.{
            .root_source_file = b.path(root),
            .target = b.resolveTargetQuery(device.device_target.target_query),
            .optimize = optimize,
        }),
    });
    kernel.root_module.addImport("kernel", kernel_module);
    kernel.root_module.addImport("config", config_module);
    kernel.setLinkerScript(b.path(b.fmt("src/arch/{s}/boot/{s}.ld", .{
        @tagName(arch),
        @tagName(device.device_target.boot),
    })));

    const out = switch (device.device_target.boot) {
        .android => |cfg| package.android(
            b,
            kernel,
            cfg,
        ),
    };

    const name = b.fmt("{s}.{s}", .{ @tagName(device_opt), out.ext });
    const install = b.addInstallBinFile(out.file, name);
    b.getInstallStep().dependOn(&install.step);

    const run_exe = switch (device.device_target.run) {
        .fastboot => runner.fastboot.run(b, install.source),
    };

    const run_step = b.step("run", "Run the target");
    run_step.dependOn(run_exe);
}
