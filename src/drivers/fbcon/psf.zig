const std = @import("std");

const iso_file = @embedFile("iso08.f16.psf");

pub const PSF1Magic: u16 = 0x0436;
pub const PSF1Header = extern struct {
    magic: u16 = 0x0436,
    fontMode: u8,
    characterSize: u8,
};

pub fn getGlyph(font: *const PSF1Header, codepoint: u8) []const u8 {
    const glyphs = @as([*]const u8, @ptrCast(@alignCast(font)));
    const character_size: usize = font.characterSize;
    const glyph_offset = @sizeOf(PSF1Header) + @as(usize, codepoint) * character_size;
    const glyph = glyphs[glyph_offset .. glyph_offset + character_size];
    return glyph;
}

pub fn getFont() *const PSF1Header {
    return @as(*const PSF1Header, @ptrCast(@alignCast(iso_file.ptr)));
}

pub fn main() error{InvalidFont}!void {
    const psf1 = @as(*const PSF1Header, @ptrCast(@alignCast(iso_file.ptr)));

    if (psf1.magic != PSF1Magic) return error.InvalidFont;
    std.debug.print("0x{x} {d} {d}", .{ psf1.magic, psf1.fontMode, psf1.characterSize });
    const glyph = getGlyph(psf1, 'A');
    for (glyph) |row| {
        for (0..8) |bit| {
            const pixel: u8 = if (((row >> @intCast(bit)) & 1) == 1) 'X' else ' ';
            std.debug.print("{c}", .{pixel});
        }
        std.debug.print("\n", .{});
    }
}
