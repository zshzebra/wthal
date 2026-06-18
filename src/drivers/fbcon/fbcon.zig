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

        fg: ColorType.Value,
        bg: ColorType.Value,
        rows: u64,
        cols: u64,
        cursor_row: u64,
        cursor_col: u64,
        scale: u64,

        io_writer: std.Io.Writer,

        pub fn init(fb: *Framebuffer, scale: u64) Self {
            return .{
                .fb = fb,
                .font = psf.getFont(),
                .fg = 0xcdd6f4,
                .bg = 0x1e1e2e,
                .rows = fb.mode.height / (16 * scale),
                .cols = fb.mode.width / (8 * scale),
                .cursor_row = 0,
                .cursor_col = 0,
                .scale = scale,
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

        fn put_char(self: *Self, char: u8) !void {
            switch (char) {
                '\n' => {
                    self.newline();
                    return;
                },
                '\r' => {
                    self.cursor_col = 0;
                    return;
                },
                else => {},
            }

            const base_x = self.cursor_col * 8 * self.scale;
            const base_y = self.cursor_row * self.font.characterSize * self.scale;
            const glyph = psf.getGlyph(self.font, char);
            for (0..self.font.characterSize) |glyph_row| {
                for (0..8) |x| {
                    const bit = 7 - x;
                    const color = if (((glyph[glyph_row] >> @intCast(bit)) & 1) == 1) self.fg else self.bg;
                    for (0..self.scale) |sy| {
                        for (0..self.scale) |sx| {
                            try self.fb.setPixel(base_x + x * self.scale + sx, base_y + glyph_row * self.scale + sy, color);
                        }
                    }
                }
            }

            self.cursor_col += 1;
            if (self.cursor_col >= self.cols) {
                self.newline();
            }
        }

        fn newline(self: *Self) void {
            self.cursor_col = 0;
            self.cursor_row += 1;
            if (self.cursor_row >= self.rows) {
                self.cursor_row = self.rows - 1;
                // TODO: Scroll
            }
        }
    };
}
