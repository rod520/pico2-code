const sokol = @import("sokol");
const display = @import("display/surface.zig");
const spec = @import("display/spec.zig");

const sapp = sokol.app;
const sg = sokol.gfx;
const sgl = sokol.gl;
const sglue = sokol.glue;
const slog = sokol.log;
const display_interface = @import("display/interface.zig");
const input_interface = @import("input/interface.zig");
const input_sim = @import("input/sim.zig");
const layout = @import("input/layout.zig");
const ui = @import("ui.zig");
const iosevka_font = @import("iosevka_font");
const TrueType = @import("TrueType");

const State = struct {
    pass_action: sg.PassAction = .{},
    pixels: []u16 = &.{},
    frameFn: *const fn (*display.Surface, *const input_interface.Interface) void = drawEmptyFrame,
    input: input_interface.Interface = input_sim.interface(),
    keyboard_pixels: [372 * 240]u16 = undefined,
    keyboard_focus: u8 = 1,
};

fn drawEmptyFrame(surface: *display.Surface, keys: *const input_interface.Interface) void {
    _ = surface;
    _ = keys;
}

var state: State = .{};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    sgl.setup(.{
        .max_vertices = spec.width * spec.height * 4,
        .max_commands = spec.height * spec.width,
        .logger = .{ .func = slog.func },
    });

    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.055, .g = 0.065, .b = 0.085, .a = 1.0 },
    };

    const font = TrueType.load(iosevka_font.bytes) catch @panic("invalid Iosevka Fixed font");
    var keyboard = display.Surface.init(state.keyboard_pixels[0..]);
    keyboard.width = 372;
    keyboard.height = 240;
    ui.drawKeyboard(&keyboard, &font, state.keyboard_focus);
}

export fn frame() void {
    var surface = display.Surface.init(state.pixels);
    state.frameFn(&surface, &state.input);
    input_sim.consumeFrame();

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sglue.swapchain(),
    });

    sgl.defaults();
    sgl.disableTexture();
    sgl.beginQuads();

    const window_width = @as(f32, @floatFromInt(sapp.width()));
    const window_height = @as(f32, @floatFromInt(sapp.height()));
    const scale = @min(window_width / spec.width, window_height / spec.height);
    const display_width = @as(f32, spec.width) * scale;
    const display_height = @as(f32, spec.height) * scale;
    const left = (window_width - display_width) * 0.5;
    const top = (window_height - display_height) * 0.5;

    var y: i32 = 0;
    while (y < spec.height) : (y += 1) {
        var x: i32 = 0;
        while (x < spec.width) {
            const index = @as(usize, @intCast(y * spec.width + x));
            const rgb565 = state.pixels[index];
            var end_x = x + 1;
            while (end_x < spec.width) : (end_x += 1) {
                const end_index = @as(usize, @intCast(y * spec.width + end_x));
                if (state.pixels[end_index] != rgb565) break;
            }

            const color = display.Color.fromRgb565(rgb565);
            const px = left + @as(f32, @floatFromInt(x)) * scale;
            const py = top + @as(f32, @floatFromInt(y)) * scale;
            const px2 = left + @as(f32, @floatFromInt(end_x)) * scale;
            const py2 = py + scale;

            const x1 = px / window_width * 2.0 - 1.0;
            const x2 = px2 / window_width * 2.0 - 1.0;
            const y1 = 1.0 - py / window_height * 2.0;
            const y2 = 1.0 - py2 / window_height * 2.0;
            sgl.v2fC3f(x1, y1, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x2, y1, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x2, y2, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x1, y2, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);

            x = end_x;
        }
    }

    y = 0;
    while (y < 240) : (y += 1) {
        var x: i32 = 0;
        while (x < 372) {
        const index = @as(usize, @intCast(y * 372 + x));
            const rgb565 = state.keyboard_pixels[index];
            var end_x = x + 1;
        while (end_x < 372) : (end_x += 1) {
            const end_index = @as(usize, @intCast(y * 372 + end_x));
                if (state.keyboard_pixels[end_index] != rgb565) break;
            }

            const color = display.Color.fromRgb565(rgb565);
            const px = 320.0 + @as(f32, @floatFromInt(x));
            const py = @as(f32, @floatFromInt(y));
            const px2 = 320.0 + @as(f32, @floatFromInt(end_x));
            const py2 = py + 1.0;

            const x1 = px / window_width * 2.0 - 1.0;
            const x2 = px2 / window_width * 2.0 - 1.0;
            const y1 = 1.0 - py / window_height * 2.0;
            const y2 = 1.0 - py2 / window_height * 2.0;
            sgl.v2fC3f(x1, y1, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x2, y1, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x2, y2, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);
            sgl.v2fC3f(x1, y2, @as(f32, color.r) / 255.0, @as(f32, color.g) / 255.0, @as(f32, color.b) / 255.0);

            x = end_x;
        }
    }

    sgl.end();
    sgl.draw();
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sgl.shutdown();
    sg.shutdown();
}

export fn event(ev: [*c]const sapp.Event) void {
    if (ev.*.type == .MOUSE_DOWN and ev.*.mouse_button == .LEFT) {
        if (ev.*.mouse_x >= 320.0 and ev.*.mouse_x < 692.0) {
            const column = @as(usize, @intFromFloat((ev.*.mouse_x - 320.0) / 62.0));
            const row = @as(usize, @intFromFloat(ev.*.mouse_y / 24.0));
            if (column < 6 and row < 10) {
                for (layout.key_buttons) |button| {
                    if (button.column == column + 1 and button.row == row + 1) {
                        state.keyboard_focus = button.sw;
                        input_sim.setKey(layout.swToKey(button.sw), true);

                        const font = TrueType.load(iosevka_font.bytes) catch return;
                        var keyboard = display.Surface.init(state.keyboard_pixels[0..]);
                        keyboard.width = 372;
                        keyboard.height = 240;
                        ui.drawKeyboard(&keyboard, &font, state.keyboard_focus);
                        return;
                    }
                }
            }
        }
    }

    const key = switch (ev.*.key_code) {
        .F1 => input_interface.Key.k1,
        .F2 => input_interface.Key.k2,
        .F3 => input_interface.Key.k3,
        .F4 => input_interface.Key.k4,
        .F5 => input_interface.Key.k5,
        .F6 => input_interface.Key.k6,
        .F7 => input_interface.Key.k7,
        .F8 => input_interface.Key.k8,
        .F9 => input_interface.Key.k9,
        .F10 => input_interface.Key.k10,
        .F11 => input_interface.Key.k11,
        .F12 => input_interface.Key.k12,
        ._1 => input_interface.Key.k14,
        ._2 => input_interface.Key.k15,
        ._3 => input_interface.Key.k16,
        ._4 => input_interface.Key.k17,
        ._5 => input_interface.Key.k18,
        ._6 => input_interface.Key.k19,
        ._7 => input_interface.Key.k20,
        ._8 => input_interface.Key.k21,
        ._9 => input_interface.Key.k22,
        ._0 => input_interface.Key.k23,
        .Q => input_interface.Key.k26,
        .W => input_interface.Key.k27,
        .E => input_interface.Key.k28,
        .R => input_interface.Key.k29,
        .T => input_interface.Key.k30,
        .Y => input_interface.Key.k31,
        .U => input_interface.Key.k32,
        .I => input_interface.Key.k33,
        .O => input_interface.Key.k34,
        .P => input_interface.Key.k35,
        .A => input_interface.Key.k38,
        .S => input_interface.Key.k39,
        .D => input_interface.Key.k40,
        .F => input_interface.Key.k41,
        .G => input_interface.Key.k42,
        .H => input_interface.Key.k43,
        .J => input_interface.Key.k44,
        .K => input_interface.Key.k45,
        .L => input_interface.Key.k46,
        .Z => input_interface.Key.k50,
        .X => input_interface.Key.k51,
        .C => input_interface.Key.k52,
        .V => input_interface.Key.k53,
        .B => input_interface.Key.k54,
        .N => input_interface.Key.k55,
        .M => input_interface.Key.k56,
        .COMMA => input_interface.Key.k57,
        .PERIOD => input_interface.Key.k58,
        .SLASH => input_interface.Key.k59,
        .BACKSPACE => input_interface.Key.k36,
        .TAB => input_interface.Key.k25,
        .RIGHT => input_interface.Key.k11,
        .LEFT => input_interface.Key.k2,
        .DOWN => input_interface.Key.k12,
        .UP => input_interface.Key.k1,
        .ENTER, .KP_ENTER => input_interface.Key.k56,
        else => return,
    };
    if (ev.*.type == .KEY_DOWN and !ev.*.key_repeat) {
        input_sim.setKey(key, true);
    }
}

pub fn interface() display_interface.Interface {
    return .{ .runFn = run };
}

fn run(
    input: *const input_interface.Interface,
    frameFn: *const fn (*display.Surface, *const input_interface.Interface) void,
) void {
    var pixels: [spec.width * spec.height]u16 = undefined;
    state.pixels = pixels[0..];
    state.input = input.*;
    state.frameFn = frameFn;
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 692,
        .height = 240,
        .window_title = "Calculator Simulator — 320 × 240 + Keyboard",
        .high_dpi = false,
        .icon = .{ .sokol_default = true },
        .depth_format = .NONE,
        .logger = .{ .func = slog.func },
        .win32 = .{ .console_attach = true },
    });
}
