const input = @import("interface.zig");

pub fn interface() input.Interface {
    return .{ .isPressedFn = isPressed };
}

fn isPressed(_: *const input.Interface, _: input.Key) bool {
    return false;
}
