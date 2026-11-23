const input = @import("interface.zig");

var pressed: [60]bool = @splat(false);

pub fn interface() input.Interface {
    return .{ .isPressedFn = isPressed };
}

fn isPressed(_: *const input.Interface, key: input.Key) bool {
    return pressed[@intFromEnum(key) - 1];
}

pub fn setKey(key: input.Key, down: bool) void {
    pressed[@intFromEnum(key) - 1] = down;
}

pub fn consumeFrame() void {
    @memset(pressed[0..], false);
}
