const Surface = @import("surface.zig").Surface;
const Input = @import("../input/interface.zig").Interface;

pub const Interface = struct {
    runFn: *const fn (*const Input, *const fn (*Surface, *const Input) void) void,

    pub fn run(
        self: Interface,
        input: *const Input,
        frameFn: *const fn (*Surface, *const Input) void,
    ) void {
        self.runFn(input, frameFn);
    }
};
