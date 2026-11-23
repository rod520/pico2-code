const surface = @import("display/surface.zig");
const input = @import("input/interface.zig");
const spec = @import("display/spec.zig");

pub const Alignment = enum {
    left,
    center,
    right,
};

pub const Grid = struct {
    origin: surface.Point = .{ .x = 0, .y = 0 },
    cell_width: i32 = 16,
    cell_height: i32 = 16,

    pub fn rect(self: Grid, column: i32, row: i32, width: i32, height: i32) surface.Rect {
        return .{
            .origin = .{
                .x = self.origin.x + column * self.cell_width,
                .y = self.origin.y + row * self.cell_height,
            },
            .size = .{
                .width = width * self.cell_width,
                .height = height * self.cell_height,
            },
        };
    }
};

fn glyphPattern(char: u8) [7]u5 {
    return switch (char) {
        'A' => .{ 0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001 },
        'C' => .{ 0b01111, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b01111 },
        'E' => .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111 },
        'L' => .{ 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111 },
        'N' => .{ 0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001 },
        'R' => .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001 },
        'T' => .{ 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100 },
        ' ' => .{ 0, 0, 0, 0, 0, 0, 0 },
        '0' => .{ 0b11111, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b11111 },
        '1' => .{ 0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110 },
        '2' => .{ 0b11111, 0b00001, 0b00001, 0b11111, 0b10000, 0b10000, 0b11111 },
        '3' => .{ 0b11111, 0b00001, 0b00001, 0b01111, 0b00001, 0b00001, 0b11111 },
        '4' => .{ 0b10001, 0b10001, 0b10001, 0b11111, 0b00001, 0b00001, 0b00001 },
        '5' => .{ 0b11111, 0b10000, 0b10000, 0b11111, 0b00001, 0b00001, 0b11111 },
        '+' => .{ 0, 0b00100, 0b00100, 0b11111, 0b00100, 0b00100, 0 },
        '=' => .{ 0, 0, 0b11111, 0, 0b11111, 0, 0 },
        else => .{ 0b11111, 0b10001, 0b10101, 0b10101, 0b10101, 0b10001, 0b11111 },
    };
}

pub fn drawText(
    display: *surface.Surface,
    origin: surface.Point,
    text: []const u8,
    color: surface.Color,
    scale: i32,
) void {
    var x = origin.x;
    for (text) |char| {
        const pattern = glyphPattern(char);
        for (pattern, 0..) |row, py| {
            for (0..5) |px| {
                if ((row & (@as(u5, 1) << @intCast(4 - px))) != 0) {
                    var sy: i32 = 0;
                    while (sy < scale) : (sy += 1) {
                        var sx: i32 = 0;
                        while (sx < scale) : (sx += 1) {
                            display.drawPixel(.{
                                .x = x + @as(i32, @intCast(px)) * scale + sx,
                                .y = origin.y + @as(i32, @intCast(py)) * scale + sy,
                            }, color);
                        }
                    }
                }
            }
        }
        x += 6 * scale;
    }
}

pub const Button = struct {
    rect: surface.Rect,
    label: []const u8,
    focused: bool = false,
    activated: bool = false,

    pub fn draw(self: *const Button, display: *surface.Surface) void {
        display.drawBorderedRect(
            self.rect,
            2,
            if (self.focused)
                surface.Color.rgb(255, 196, 64)
            else
                surface.Color.rgb(180, 180, 180),
            surface.Color.rgb(35, 40, 52),
        );

        const text_width = @as(i32, @intCast(self.label.len)) * 6;
        drawText(
            display,
            .{
                .x = self.rect.origin.x + @divTrunc(self.rect.size.width - text_width, 2),
                .y = self.rect.origin.y + @divTrunc(self.rect.size.height - 7, 2),
            },
            self.label,
            if (self.activated)
                surface.Color.rgb(255, 255, 255)
            else
                surface.Color.rgb(210, 210, 210),
            1,
        );
    }
};

pub const Screen = struct {
    grid: Grid = .{},
    title: []const u8,
    expression: []const u8,
    buttons: [2]Button,
    focus_index: usize = 0,
    activated_index: ?usize = null,

    pub fn init() Screen {
        const grid: Grid = .{};
        var buttons: [2]Button = undefined;
        buttons[0] = .{
            .rect = grid.rect(1, 11, 5, 2),
            .label = "ENTER",
            .focused = true,
        };
        buttons[1] = .{
            .rect = grid.rect(14, 11, 5, 2),
            .label = "CLEAR",
        };
        return .{
            .title = "CALCULATOR",
            .expression = "123 + 45",
            .buttons = buttons,
        };
    }

    pub fn update(self: *Screen, keys: *const input.Interface) void {
        if (keys.isPressed(.k11) or keys.isPressed(.k12)) {
            self.focus_index = (self.focus_index + 1) % self.buttons.len;
        } else if (keys.isPressed(.k2) or keys.isPressed(.k1)) {
            self.focus_index = (self.focus_index + self.buttons.len - 1) % self.buttons.len;
        }

        for (&self.buttons, 0..) |*button, index| {
            button.focused = index == self.focus_index;
        }

        if (keys.isPressed(.k60)) {
            self.activated_index = self.focus_index;
            self.buttons[self.focus_index].activated = !self.buttons[self.focus_index].activated;
        }
    }

    pub fn draw(self: *Screen, display: *surface.Surface) void {
        display.clear(surface.Color.rgb(20, 24, 34));
        display.drawBorderedRect(
            self.grid.rect(1, 1, 18, 2),
            1,
            surface.Color.rgb(84, 196, 255),
            surface.Color.rgb(35, 40, 52),
        );
        drawText(display, .{ .x = 24, .y = 28 }, self.title, surface.Color.rgb(255, 255, 255), 2);

        display.drawBorderedRect(
            self.grid.rect(1, 4, 18, 5),
            2,
            surface.Color.rgb(180, 180, 180),
            surface.Color.rgb(12, 16, 24),
        );
        drawText(display, .{ .x = 32, .y = 88 }, self.expression, surface.Color.rgb(255, 196, 64), 2);

        for (&self.buttons) |*button| button.draw(display);
    }
};

test "fixed grid creates display rectangles" {
    const grid: Grid = .{};
    const rect = grid.rect(1, 11, 5, 2);
    try @import("std").testing.expectEqual(@as(i32, 16), rect.origin.x);
    try @import("std").testing.expectEqual(@as(i32, 176), rect.origin.y);
    try @import("std").testing.expectEqual(@as(i32, 80), rect.size.width);
    try @import("std").testing.expectEqual(@as(i32, 32), rect.size.height);
}
