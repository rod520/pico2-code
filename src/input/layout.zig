const input = @import("interface.zig");

pub const KeyButton = struct {
    sw: u8,
    column: u8,
    row: u8,
    primary: []const u8,
};

pub const key_buttons = [_]KeyButton{
    .{ .sw = 1, .column = 1, .row = 1, .primary = "UP" },
    .{ .sw = 2, .column = 1, .row = 2, .primary = "LEFT" },
    .{ .sw = 3, .column = 1, .row = 3, .primary = "MENU" },
    .{ .sw = 4, .column = 1, .row = 4, .primary = "TRIG" },
    .{ .sw = 5, .column = 1, .row = 5, .primary = "X,T..." },
    .{ .sw = 6, .column = 1, .row = 6, .primary = "x^2" },
    .{ .sw = 7, .column = 1, .row = 7, .primary = "ALPHA" },
    .{ .sw = 8, .column = 1, .row = 8, .primary = "SHIFT" },
    .{ .sw = 9, .column = 1, .row = 9, .primary = "CTRL" },
    .{ .sw = 10, .column = 1, .row = 10, .primary = "ON" },
    .{ .sw = 11, .column = 2, .row = 1, .primary = "RIGHT" },
    .{ .sw = 12, .column = 2, .row = 2, .primary = "DOWN" },
    .{ .sw = 13, .column = 2, .row = 3, .primary = "USER" },
    .{ .sw = 14, .column = 2, .row = 4, .primary = "cis" },
    .{ .sw = 15, .column = 2, .row = 5, .primary = "STO>" },
    .{ .sw = 16, .column = 2, .row = 6, .primary = "EE" },
    .{ .sw = 17, .column = 2, .row = 7, .primary = "MAT" },
    .{ .sw = 18, .column = 2, .row = 8, .primary = "ALG" },
    .{ .sw = 19, .column = 2, .row = 9, .primary = "CPLX" },
    .{ .sw = 20, .column = 2, .row = 10, .primary = "SPACE" },
    .{ .sw = 21, .column = 3, .row = 1, .primary = "SEL1" },
    .{ .sw = 22, .column = 3, .row = 2, .primary = "HOME" },
    .{ .sw = 23, .column = 3, .row = 3, .primary = "VARS" },
    .{ .sw = 24, .column = 3, .row = 4, .primary = "UNIT" },
    .{ .sw = 25, .column = 3, .row = 5, .primary = "(" },
    .{ .sw = 26, .column = 3, .row = 6, .primary = "x^-1" },
    .{ .sw = 27, .column = 3, .row = 7, .primary = "7" },
    .{ .sw = 28, .column = 3, .row = 8, .primary = "4" },
    .{ .sw = 29, .column = 3, .row = 9, .primary = "1" },
    .{ .sw = 30, .column = 3, .row = 10, .primary = "0" },
    .{ .sw = 31, .column = 4, .row = 1, .primary = "SEL2" },
    .{ .sw = 32, .column = 4, .row = 2, .primary = "SYMB" },
    .{ .sw = 33, .column = 4, .row = 3, .primary = "TMPL" },
    .{ .sw = 34, .column = 4, .row = 4, .primary = "x^y" },
    .{ .sw = 35, .column = 4, .row = 5, .primary = ")" },
    .{ .sw = 36, .column = 4, .row = 6, .primary = "=" },
    .{ .sw = 37, .column = 4, .row = 7, .primary = "8" },
    .{ .sw = 38, .column = 4, .row = 8, .primary = "5" },
    .{ .sw = 39, .column = 4, .row = 9, .primary = "2" },
    .{ .sw = 40, .column = 4, .row = 10, .primary = "." },
    .{ .sw = 41, .column = 5, .row = 1, .primary = "SEL3" },
    .{ .sw = 42, .column = 5, .row = 2, .primary = "PLOT" },
    .{ .sw = 43, .column = 5, .row = 3, .primary = "ESC" },
    .{ .sw = 44, .column = 5, .row = 4, .primary = "log" },
    .{ .sw = 45, .column = 5, .row = 5, .primary = "," },
    .{ .sw = 46, .column = 5, .row = 6, .primary = "SOLVE" },
    .{ .sw = 47, .column = 5, .row = 7, .primary = "9" },
    .{ .sw = 48, .column = 5, .row = 8, .primary = "6" },
    .{ .sw = 49, .column = 5, .row = 9, .primary = "3" },
    .{ .sw = 50, .column = 5, .row = 10, .primary = "(-)" },
    .{ .sw = 51, .column = 6, .row = 1, .primary = "SEL4" },
    .{ .sw = 52, .column = 6, .row = 2, .primary = "NUM" },
    .{ .sw = 53, .column = 6, .row = 3, .primary = "ANS" },
    .{ .sw = 54, .column = 6, .row = 4, .primary = "ln" },
    .{ .sw = 55, .column = 6, .row = 5, .primary = "BKSP" },
    .{ .sw = 56, .column = 6, .row = 6, .primary = "ENTER" },
    .{ .sw = 57, .column = 6, .row = 7, .primary = "/" },
    .{ .sw = 58, .column = 6, .row = 8, .primary = "*" },
    .{ .sw = 59, .column = 6, .row = 9, .primary = "-" },
    .{ .sw = 60, .column = 6, .row = 10, .primary = "+" },
};

pub fn swToKey(sw: u8) input.Key {
    return @enumFromInt(sw);
}

test "layout contains 60 switches" {
    try @import("std").testing.expectEqual(@as(usize, 60), key_buttons.len);
}
