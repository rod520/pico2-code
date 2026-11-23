const std = @import("std");
const build_options = @import("build_options");
const surface = @import("display/surface.zig");
const spec = @import("display/spec.zig");
const input = @import("input/interface.zig");
const ui = @import("ui.zig");

pub fn main() void {
    const display_interface = if (comptime std.mem.eql(u8, build_options.mode, "sim"))
        @import("sim.zig").interface()
    else
        @import("native.zig").interface();
    var input_interface = if (comptime std.mem.eql(u8, build_options.mode, "sim"))
        @import("input/sim.zig").interface()
    else
        @import("input/native.zig").interface();

    display_interface.run(&input_interface, drawUiDemo);
}

var screen = ui.Screen.init();

fn drawUiDemo(display: *surface.Surface, keys: *const input.Interface) void {
    screen.update(keys);
    screen.draw(display);
}
