/// Physical LCD dimensions reported for the E26RE-RW300-N configuration.
pub const width: comptime_int = 320;
pub const height: comptime_int = 240;

/// The controller-facing framebuffer will use RGB565.
pub const aspect_ratio_num: comptime_int = 4;
pub const aspect_ratio_den: comptime_int = 3;

pub const framebuffer_bytes: comptime_int = width * height * 2;

test "display geometry is 4:3" {
    try @import("std").testing.expect(width * aspect_ratio_den == height * aspect_ratio_num);
}
