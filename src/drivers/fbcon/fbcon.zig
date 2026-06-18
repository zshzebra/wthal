const std = @import("std");
const framebuffer = @import("../framebuffer/framebuffer.zig");
const psf = @import("psf.zig");

pub fn FbCon(comptime kind: framebuffer.ColorKind) type {
    return struct {
        const Self = @This();
        const Framebuffer = framebuffer.Framebuffer(kind);
        const ColorType = framebuffer.Color(kind);

        fb: *Framebuffer,

        font: *const psf.PSF1Header,

        fg: ColorType,
        bg: ColorType,
        rows: u64,
        cols: u64,
        cursor_row: u64,
        cursor_col: u64,

        io_writer: std.Io.Writer,

        pub fn init(fb: *Framebuffer) Self {
            return .{
                .fb = fb,
                .font = psf.getFont(),
                .rows = fb.mode.height / 16,
                .cols = fb.mode.width / 8,
                .cursor_row = 0,
                .cursor_col = 0,
                .io_writer = .{
                    .vtable = &.{
                        .drain = drain,
                        .flush = std.Io.Writer.noopFlush,
                    },
                    .buffer = &.{},
                },
            };
        }

        pub fn writer(self: *Self) *std.Io.Writer {
            return &self.io_writer;
        }

        fn drain(
            w: *std.Io.Writer,
            data: []const []const u8,
            splat: usize,
        ) std.Io.Writer.Error!usize {
            const self: *Self = @alignCast(@fieldParentPtr("io_writer", w));

            var written: usize = 0;

            for (data[0 .. data.len - 1]) |bytes| {
                self.write_all(bytes) catch return error.WriteFailed;
                written += bytes.len;
            }

            const repeated = data[data.len - 1];
            for (0..splat) |_| {
                self.write_all(repeated) catch return error.WriteFailed;
                written += repeated.len;
            }

            return written;
        }

        fn write_all(self: *Self, bytes: []const u8) !void {
            for (bytes) |char| {
                try self.put_char(char);
            }
        }

        fn put_char(self: *Self, row: u64, col: u64, char: u8) !void {
            const base_x = (self.fb.mode.width / self.rows) * row;
            const base_y = (self.fb.mode.height / self.cols) * col;
            const glyph = psf.getGlyph(self.font, char);
            for (0..self.font.characterSize) |glyph_row| {
                for (0..8) |x| {
                    const color: ColorType = if (((glyph[glyph_row] >> @intCast(x)) & 1) == 1) self.fg else self.bg;
                    try self.fb.setPixel(base_x + x, base_y + glyph_row, color);
                }
            }
            self.cursor_col += 1;
            if (self.cursor_row > self.rows) {
                self.cursor_col = 0;
                self.cursor_col += 1;
                if (self.cursor_col > self.cols) {
                    // TODO: Scroll
                }
            }
        }
    };
}
