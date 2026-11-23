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

const State = struct {
    pass_action: sg.PassAction = .{},
    pixels: []u16 = &.{},
    frameFn: *const fn (*display.Surface, *const input_interface.Interface) void = drawEmptyFrame,
    input: input_interface.Interface = input_sim.interface(),
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
    const key = switch (ev.*.key_code) {
        .UP => input_interface.Key.k1,
        .RIGHT => input_interface.Key.k11,
        .DOWN => input_interface.Key.k12,
        .LEFT => input_interface.Key.k2,
        .ENTER, .KP_ENTER => input_interface.Key.k60,
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
        .width = spec.width,
        .height = spec.height,
        .window_title = "Calculator Simulator — 320 × 240",
        .high_dpi = false,
        .icon = .{ .sokol_default = true },
        .depth_format = .NONE,
        .logger = .{ .func = slog.func },
        .win32 = .{ .console_attach = true },
    });
}
