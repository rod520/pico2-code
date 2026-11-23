pub const pico_sram_bytes: comptime_int = 520 * 1024;
pub const pico_psram_bytes: comptime_int = 8 * 1024 * 1024;

pub const framebuffer_bytes: comptime_int = 320 * 240 * 2;
pub const key_state_bytes: comptime_int = 60;
pub const dirty_rect_bytes: comptime_int = 16;

pub const pico_sram_reserve_bytes: comptime_int =
    key_state_bytes + dirty_rect_bytes;

test "framebuffer and small state fit Pico memory" {
    const std = @import("std");
    try std.testing.expect(framebuffer_bytes <= pico_psram_bytes);
    try std.testing.expect(pico_sram_reserve_bytes <= pico_sram_bytes);
}

test "display RGB565 framebuffer is exactly 150 KiB" {
    const std = @import("std");
    try std.testing.expectEqual(@as(comptime_int, 153600), framebuffer_bytes);
    try std.testing.expect(framebuffer_bytes < pico_sram_bytes);
}
