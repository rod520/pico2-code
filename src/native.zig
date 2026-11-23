const std = @import("std");
const display_interface = @import("display/interface.zig");
const Surface = @import("display/surface.zig").Surface;
const Input = @import("input/interface.zig").Interface;
const spec = @import("display/spec.zig");

pub fn interface() display_interface.Interface {
    return .{ .runFn = run };
}

fn run(_: *const Input, frameFn: *const fn (*Surface, *const Input) void) void {
    var pixels: [spec.width * spec.height]u16 = undefined;
    const surface = Surface.init(pixels[0..]);
    _ = frameFn;
    _ = surface;
    std.debug.print("Native backend selected; RP2350 display implementation is not connected yet.\n", .{});
}
