const std = @import("std");
const TrueType = @import("TrueType");
const surface = @import("display/surface.zig");
const input = @import("input/interface.zig");

const iosevka_font = @import("iosevka_font");
const font_bytes = iosevka_font.bytes;

pub fn drawText(
    display: *surface.Surface,
    font: *const TrueType,
    origin: surface.Point,
    text: []const u8,
    pixel_height: f32,
    color: surface.Color,
) void {
    const scale = font.scaleForPixelHeight(pixel_height);
    var x = origin.x;
    var previous: ?TrueType.GlyphIndex = null;

    for (text) |byte| {
        const glyph = font.codepointGlyphIndex(byte);
        if (previous) |a| {
            const kern = @as(f32, @floatFromInt(font.glyphKernAdvance(a, glyph))) * scale / 64.0;
            x += @as(i32, @intFromFloat(kern));
        }

        var pixels: std.ArrayList(u8) = .empty;
        const dims = font.glyphBitmap(std.heap.smp_allocator, &pixels, glyph, scale, scale) catch return;
        defer pixels.deinit(std.heap.smp_allocator);

        var py: i32 = 0;
        while (py < dims.height) : (py += 1) {
            var px: i32 = 0;
            while (px < dims.width) : (px += 1) {
                const alpha = pixels.items[@as(usize, @intCast(py * dims.width + px))];
                display.drawPixelAlpha(.{
                    .x = x + px + dims.off_x,
                    .y = origin.y + py + dims.off_y,
                }, color, alpha);
            }
        }

        const metrics = font.glyphHMetrics(glyph);
        x += @as(i32, @intFromFloat(@as(f32, @floatFromInt(metrics.advance_width)) * scale + 0.5));
        previous = glyph;
    }
}

pub fn textWidth(
    font: *const TrueType,
    text: []const u8,
    pixel_height: f32,
) i32 {
    const scale = font.scaleForPixelHeight(pixel_height);
    var width: i32 = 0;
    var previous: ?TrueType.GlyphIndex = null;

    for (text) |byte| {
        const glyph = font.codepointGlyphIndex(byte);
        if (previous) |a| {
            const kern = @as(f32, @floatFromInt(font.glyphKernAdvance(a, glyph))) * scale / 64.0;
            width += @as(i32, @intFromFloat(kern));
        }
        const metrics = font.glyphHMetrics(glyph);
        width += @as(i32, @intFromFloat(@as(f32, @floatFromInt(metrics.advance_width)) * scale + 0.5));
        previous = glyph;
    }
    return width;
}

const layout = @import("input/layout.zig");

pub fn drawKeyboard(
    display: *surface.Surface,
    font: *const TrueType,
    focus_sw: u8,
) void {
    display.clear(surface.Color.rgb(12, 16, 24));

    for (layout.key_buttons) |button| {
        const column = @as(i32, button.column - 1);
        const row = @as(i32, button.row - 1);
        const rect = surface.Rect{
            .origin = .{
                .x = column * 62 + 2,
                .y = row * 24 + 2,
            },
            .size = .{ .width = 58, .height = 20 },
        };
        display.drawBorderedRect(
            rect,
            1,
            if (button.sw == focus_sw)
                surface.Color.rgb(255, 196, 64)
            else
                surface.Color.rgb(150, 150, 150),
            surface.Color.rgb(35, 40, 52),
        );

        drawText(
            display,
            font,
            .{
                .x = rect.origin.x + @divTrunc(rect.size.width - textWidth(font, button.primary, 18), 2),
                .y = rect.origin.y + @divTrunc(rect.size.height - 12, 2) + 12,
            },
            button.primary,
            18,
            surface.Color.rgb(230, 230, 230),
        );
    }
}

pub const Screen = struct {
    font: TrueType,
    cursor: usize = 7,
    expression: [32]u8 = @splat(0),
    expression_len: usize = 0,
    cursor_visible: bool = true,
    cursor_frames: u32 = 0,

    pub fn init() Screen {
        const font = TrueType.load(font_bytes) catch @panic("invalid Iosevka Fixed font");
        var expression: [32]u8 = @splat(0);
        const demo = "123+45";
        @memcpy(expression[0..demo.len], demo);
        return .{
            .font = font,
            .expression = expression,
            .expression_len = demo.len,
        };
    }

    pub fn update(self: *Screen, keys: *const input.Interface) void {
        self.cursor_frames +%= 1;
        if (self.cursor_frames % 30 == 0) self.cursor_visible = !self.cursor_visible;

        const character: ?u8 = if (keys.isPressed(.k30))
            '0'
        else if (keys.isPressed(.k29))
            '1'
        else if (keys.isPressed(.k39))
            '2'
        else if (keys.isPressed(.k49))
            '3'
        else if (keys.isPressed(.k28))
            '4'
        else if (keys.isPressed(.k38))
            '5'
        else if (keys.isPressed(.k48))
            '6'
        else if (keys.isPressed(.k27))
            '7'
        else if (keys.isPressed(.k37))
            '8'
        else if (keys.isPressed(.k47))
            '9'
        else if (keys.isPressed(.k40))
            '.'
        else if (keys.isPressed(.k25))
            '('
        else if (keys.isPressed(.k35))
            ')'
        else if (keys.isPressed(.k57))
            '/'
        else if (keys.isPressed(.k58))
            '*'
        else if (keys.isPressed(.k59))
            '-'
        else if (keys.isPressed(.k60))
            '+'
        else
            null;

        if (character) |char| {
            if (self.expression_len < self.expression.len) {
                if (self.cursor < self.expression_len) {
                    var i = self.expression_len;
                    while (i > self.cursor) : (i -= 1) {
                        self.expression[i] = self.expression[i - 1];
                    }
                }
                self.expression[self.cursor] = char;
                self.expression_len += 1;
                self.cursor += 1;
            }
        }

        if (keys.isPressed(.k36) and self.expression_len < self.expression.len) {
            self.expression[self.expression_len] = '=';
            self.expression_len += 1;
        } else if (keys.isPressed(.k56) and self.expression_len < self.expression.len) {
            self.expression[self.expression_len] = '=';
            self.expression_len += 1;
        }

        if (keys.isPressed(.k55) and self.cursor > 0) {
            var i = self.cursor - 1;
            while (i < self.expression_len - 1) : (i += 1) {
                self.expression[i] = self.expression[i + 1];
            }
            self.expression_len -= 1;
            self.cursor -= 1;
        }

        if (keys.isPressed(.k2)) self.cursor = @max(0, self.cursor - 1);
        if (keys.isPressed(.k11)) self.cursor = @min(self.expression_len, self.cursor + 1);
    }

    pub fn draw(self: *Screen, display: *surface.Surface) void {
        display.clear(surface.Color.rgb(20, 24, 34));

        display.drawBorderedRect(
            .{
                .origin = .{ .x = 8, .y = 8 },
                .size = .{ .width = 304, .height = 72 },
            },
            2,
            surface.Color.rgb(84, 196, 255),
            surface.Color.rgb(12, 16, 24),
        );

        drawText(
            display,
            &self.font,
            .{ .x = 16, .y = 24 },
            self.expression[0..self.expression_len],
            18,
            surface.Color.rgb(255, 255, 255),
        );

        if (self.cursor_visible) {
            const cursor_x: i32 = 16 + textWidth(
                &self.font,
                self.expression[0..self.cursor],
                18,
            );
            display.drawRect(.{
                .origin = .{ .x = cursor_x, .y = 12 },
                .size = .{ .width = 2, .height = 13 },
            }, surface.Color.rgb(255, 196, 64));
        }

    }
};
