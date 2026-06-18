pub const ColorKind = enum {
    rgb,
};

fn scale(v: u8, bits: u8) u32 {
    return @as(u32, v) >> @intCast(8 - bits);
}

pub const Rgb = struct {
    pub const Value = u32;

    pub const Format = struct {
        red_mask_size: u8,
        red_mask_shift: u8,
        green_mask_size: u8,
        green_mask_shift: u8,
        blue_mask_size: u8,
        blue_mask_shift: u8,
    };

    pub fn pack(fmt: Format, value: Value) u32 {
        return blk: {
            const r = scale(@truncate(value >> 16), fmt.red_mask_size) << @intCast(fmt.red_mask_shift);
            const g = scale(@truncate(value >> 8), fmt.green_mask_size) << @intCast(fmt.green_mask_shift);
            const b = scale(@truncate(value), fmt.blue_mask_size) << @intCast(fmt.blue_mask_shift);
            break :blk r | g | b;
        };
    }
};

fn Color(comptime k: ColorKind) type {
    return switch (k) {
        .rgb => Rgb,
    };
}

pub fn Framebuffer(comptime kind: ColorKind) type {
    const ColorType = Color(kind);

    return struct {
        const Self = @This();

        buffer: []volatile u32,
        mode: VideoMode(kind),

        pub fn clear(self: *Self, color: ColorType.Value) void {
            @memset(self.buffer, ColorType.pack(self.mode.color_format, color));
        }
    };
}

pub fn VideoMode(comptime kind: ColorKind) type {
    return struct {
        width: u64,
        height: u64,
        pitch: u64,
        bpp: u16,
        color_format: Color(kind).Format,
    };
}
