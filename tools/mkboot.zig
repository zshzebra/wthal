const std = @import("std");

const BootHeaderV2 = extern struct {
    magic: [8]u8 = "ANDROID!".*,
    kernel_size: u32 = 0,
    kernel_addr: u32 = 0x00008000,
    ramdisk_size: u32 = 0,
    ramdisk_addr: u32 = 0x01000000,
    second_size: u32 = 0,
    second_addr: u32 = 0,
    tags_addr: u32 = 0x00000100,
    page_size: u32 = 0,
    header_version: u32 = 0,
    os_version: u32 = 0x1e00019b,
    name: [16]u8 = @splat(0),
    cmdline: [512]u8 = @splat(0),
    id: [32]u8 = @splat(0),
    extra_cmdline: [1024]u8 = @splat(0),
    recovery_dtbo_size: u32 = 0,
    recovery_dtbo_offset: u64 align(1) = 0,
    header_size: u32 = 0,
    dtb_size: u32 = 0,
    dtb_addr: u64 align(1) = 0,
};

fn alignUp(n: usize, alignment: usize) usize {
    return (n + alignment - 1) / alignment * alignment;
}

fn updateLen(sha1: *std.crypto.hash.Sha1, len: usize) void {
    var buf: [4]u8 = undefined;
    std.mem.writeInt(u32, &buf, @intCast(len), .little);
    sha1.update(&buf);
}

fn bootId(kernel: []const u8) [20]u8 {
    var sha1 = std.crypto.hash.Sha1.init(.{});
    sha1.update(kernel);
    updateLen(&sha1, kernel.len);
    inline for (0..4) |_| updateLen(&sha1, 0);
    var out: [20]u8 = undefined;
    sha1.final(&out);
    return out;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);
    if (args.len < 5) {
        std.debug.print("usage: {s} <kernel.lz4> <out.img> <page_size> <header_version> [cmdline]\n", .{args[0]});
        return error.InvalidArgs;
    }

    const page_size = try std.fmt.parseInt(u32, args[3], 0);
    const header_version = try std.fmt.parseInt(u32, args[4], 0);
    const cmdline: []const u8 = if (args.len > 5) args[5] else "";
    if (cmdline.len > 512) return error.CmdlineTooLong;

    const kernel = try std.Io.Dir.cwd().readFileAlloc(io, args[1], allocator, .limited(64 * 1024 * 1024));

    var header: BootHeaderV2 = .{
        .kernel_size = @intCast(kernel.len),
        .page_size = page_size,
        .header_version = header_version,
        .recovery_dtbo_offset = page_size + alignUp(kernel.len, page_size),
        .header_size = @sizeOf(BootHeaderV2),
        .dtb_size = 0,
    };
    @memcpy(header.cmdline[0..cmdline.len], cmdline);
    @memcpy(header.id[0..20], &bootId(kernel));

    const page = try allocator.alloc(u8, page_size);
    @memset(page, 0);
    @memcpy(page[0..@sizeOf(BootHeaderV2)], std.mem.asBytes(&header));

    var out = try std.Io.Dir.cwd().createFile(io, args[2], .{});
    defer out.close(io);
    try out.writeStreamingAll(io, page);
    try out.writeStreamingAll(io, kernel);

    const pad = alignUp(kernel.len, page_size) - kernel.len;
    if (pad != 0) {
        const zeros = try allocator.alloc(u8, pad);
        @memset(zeros, 0);
        try out.writeStreamingAll(io, zeros);
    }
}
