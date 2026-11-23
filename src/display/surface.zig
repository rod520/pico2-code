const spec = @import("spec.zig");

pub const Point = struct {
    x: i32,
    y: i32,

    pub fn offset(self: Point, dx: i32, dy: i32) Point {
        return .{ .x = self.x + dx, .y = self.y + dy };
    }
};

pub const Size = struct {
    width: i32,
    height: i32,
};

pub const Rect = struct {
    origin: Point,
    size: Size,
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn rgb565(self: Color) u16 {
        const r = @as(u16, self.r >> 3);
        const g = @as(u16, self.g >> 2);
        const b = @as(u16, self.b >> 3);
        return (r << 11) | (g << 5) | b;
    }

    pub fn fromRgb565(value: u16) Color {
        return .{
            .r = @intCast((value >> 11) << 3),
            .g = @intCast(((value >> 5) & 0x3f) << 2),
            .b = @intCast((value & 0x1f) << 3),
        };
    }
};

pub const Surface = struct {
    pixels: []u16,
    width: i32,
    height: i32,

    pub fn init(pixels: []u16) Surface {
        return .{
            .pixels = pixels,
            .width = spec.width,
            .height = spec.height,
        };
    }

    pub fn clear(self: *Surface, color: Color) void {
        @memset(self.pixels, color.rgb565());
    }

    pub fn drawPixel(self: *Surface, point: Point, color: Color) void {
        if (point.x < 0 or point.y < 0 or point.x >= self.width or point.y >= self.height) return;
        const index = @as(usize, @intCast(point.y)) * @as(usize, @intCast(self.width)) +
            @as(usize, @intCast(point.x));
        self.pixels[index] = color.rgb565();
    }

    pub fn drawPixelFrom(self: *Surface, reference: Point, offset: Point, color: Color) void {
        self.drawPixel(reference.offset(offset.x, offset.y), color);
    }

    pub fn drawRect(self: *Surface, rect: Rect, color: Color) void {
        if (rect.size.width <= 0 or rect.size.height <= 0) return;

        var y = rect.origin.y;
        const bottom = rect.origin.y + rect.size.height;
        while (y < bottom) : (y += 1) {
            var x = rect.origin.x;
            const right = rect.origin.x + rect.size.width;
            while (x < right) : (x += 1) {
                self.drawPixel(.{ .x = x, .y = y }, color);
            }
        }
    }

    pub fn drawBorderedRect(
            self: *Surface,
            rect: Rect,
            border_width: i32,
            border_color: Color,
            fill_color: ?Color,
        ) void {
            if (rect.size.width <= 0 or rect.size.height <= 0) return;
            if (border_width <= 0) {
                if (fill_color) |fill| self.drawRect(rect, fill);
                return;
            }

            if (fill_color) |fill| self.drawRect(rect, fill);

            const top = rect.origin.y;
            const left = rect.origin.x;
            const right = rect.origin.x + rect.size.width;
            const bottom = rect.origin.y + rect.size.height;
            var thickness = border_width;
            if (thickness * 2 > rect.size.width) thickness = @divTrunc(rect.size.width, 2);
            if (thickness * 2 > rect.size.height) thickness = @min(thickness, @divTrunc(rect.size.height, 2));

            self.drawRect(.{
                .origin = .{ .x = left, .y = top },
                .size = .{ .width = rect.size.width, .height = thickness },
            }, border_color);
            self.drawRect(.{
                .origin = .{ .x = left, .y = bottom - thickness },
                .size = .{ .width = rect.size.width, .height = thickness },
            }, border_color);
            self.drawRect(.{
                .origin = .{ .x = left, .y = top },
                .size = .{ .width = thickness, .height = rect.size.height },
            }, border_color);
            self.drawRect(.{
                .origin = .{ .x = right - thickness, .y = top },
                .size = .{ .width = thickness, .height = rect.size.height },
            }, border_color);
        }

    pub fn pixel(self: *const Surface, point: Point) ?u16 {
        if (point.x < 0 or point.y < 0 or point.x >= self.width or point.y >= self.height) return null;
        const index = @as(usize, @intCast(point.y)) * @as(usize, @intCast(self.width)) +
            @as(usize, @intCast(point.x));
        return self.pixels[index];
    }
};

test "pixels and rectangles are clipped" {
    var pixels: [16]u16 = undefined;
    var surface = Surface.init(pixels[0..]);
    surface.width = 4;
    surface.height = 4;

    surface.clear(Color.rgb(0, 0, 0));
    surface.drawPixel(.{ .x = -1, .y = 0 }, Color.rgb(255, 0, 0));
    surface.drawRect(.{
        .origin = .{ .x = 3, .y = 3 },
        .size = .{ .width = 3, .height = 2 },
    }, Color.rgb(0, 255, 0));

    try @import("std").testing.expect(surface.pixel(.{ .x = 3, .y = 3 }) != null);
    try @import("std").testing.expect(surface.pixel(.{ .x = 4, .y = 3 }) == null);
}

test "reference point offset draws a pixel" {
    var pixels: [16]u16 = undefined;
    var surface = Surface.init(pixels[0..]);
    surface.width = 4;
    surface.height = 4;

    surface.clear(Color.rgb(0, 0, 0));
    surface.drawPixelFrom(
        .{ .x = 2, .y = 2 },
        .{ .x = 1, .y = -1 },
        Color.rgb(255, 255, 255),
    );

    try @import("std").testing.expectEqual(
        Color.rgb(255, 255, 255).rgb565(),
        surface.pixel(.{ .x = 3, .y = 1 }),
    );
}

test "later rectangle replaces earlier rectangle" {
    var pixels: [16]u16 = undefined;
    var surface = Surface.init(pixels[0..]);
    surface.width = 4;
    surface.height = 4;

    surface.clear(Color.rgb(20, 24, 34));
    surface.drawRect(.{
        .origin = .{ .x = 1, .y = 1 },
        .size = .{ .width = 2, .height = 2 },
    }, Color.rgb(84, 196, 255));
    surface.drawRect(.{
        .origin = .{ .x = 1, .y = 1 },
        .size = .{ .width = 1, .height = 1 },
    }, Color.rgb(255, 255, 255));

    try @import("std").testing.expectEqual(
        Color.rgb(255, 255, 255).rgb565(),
        surface.pixel(.{ .x = 1, .y = 1 }),
    );
    try @import("std").testing.expectEqual(
        Color.rgb(84, 196, 255).rgb565(),
        surface.pixel(.{ .x = 2, .y = 1 }),
    );
}

test "bordered rectangle supports clear fill" {
    var pixels: [16]u16 = undefined;
    var surface = Surface.init(pixels[0..]);
    surface.width = 4;
    surface.height = 4;

    surface.clear(Color.rgb(20, 24, 34));
    surface.drawBorderedRect(.{
        .origin = .{ .x = 0, .y = 0 },
        .size = .{ .width = 4, .height = 4 },
    }, 1, Color.rgb(255, 255, 255), null);

    try @import("std").testing.expectEqual(
        Color.rgb(255, 255, 255).rgb565(),
        surface.pixel(.{ .x = 0, .y = 1 }),
    );
    try @import("std").testing.expectEqual(
        Color.rgb(20, 24, 34).rgb565(),
        surface.pixel(.{ .x = 2, .y = 1 }),
    );
}
