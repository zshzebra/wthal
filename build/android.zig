const std = @import("std");
const registry = @import("../src/devices/registry.zig");
const Output = @import("./package.zig").Output;

pub fn package(b: *std.Build, exe: *std.Build.Step.Compile, cfg: registry.AndroidImage) Output {
    const image = exe.addObjCopy(.{ .basename = "Image", .format = .bin });

    const lz4 = b.addSystemCommand(&.{ "lz4", "-q", "-f", "-12" });
    lz4.addFileArg(image.getOutput());
    const image_lz4 = lz4.addOutputFileArg("Image.lzf4");

    const mkboot_exe = b.addExecutable(.{
        .name = "mkboot",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/mkboot.zig"),
            .target = b.graph.host,
        }),
    });
    const mkboot = b.addRunArtifact(mkboot_exe);
    mkboot.addFileArg(image_lz4);
    const boot_img = mkboot.addOutputFileArg("boot.img");
    mkboot.addArg(b.fmt("{d}", .{cfg.pagesize}));
    mkboot.addArg(b.fmt("{d}", .{cfg.header_version}));
    mkboot.addArg(cfg.cmdline);

    const avb = b.addSystemCommand(&.{ "sh", "-c", "cp \"$1\" \"$2\" && avbtool add_hash_footer --partition_name boot --partition_size \"$3\" --image \"$2\"", "avb" });
    avb.addFileArg(boot_img);
    const signed = avb.addOutputFileArg("flame.img");
    avb.addArg(b.fmt("{d}", .{cfg.partition_size}));
    return .{ .file = signed, .ext = "img" };
}
