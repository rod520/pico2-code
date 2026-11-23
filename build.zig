const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const sokol_dep = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    const truetype_dep = b.dependency("truetype", .{
        .target = target,
        .optimize = optimize,
    });

    const sim_options = b.addOptions();
    sim_options.addOption([]const u8, "mode", "sim");
    const sim_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    sim_module.addImport("build_options", sim_options.createModule());
    sim_module.addImport("sokol", sokol_dep.module("sokol"));
    sim_module.addImport("TrueType", truetype_dep.module("TrueType"));
    const sim_exe = b.addExecutable(.{
        .name = "calculator-sim",
        .root_module = sim_module,
    });

    const native_options = b.addOptions();
    native_options.addOption([]const u8, "mode", "native");
    const native_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    native_module.addImport("build_options", native_options.createModule());
    native_module.addImport("TrueType", truetype_dep.module("TrueType"));
    const native_exe = b.addExecutable(.{
        .name = "calculator-native",
        .root_module = native_module,
    });

    const sim_step = b.step("sim", "Build the desktop simulator");
    const sim_install = b.addInstallArtifact(sim_exe, .{});
    sim_step.dependOn(&sim_install.step);
    b.getInstallStep().dependOn(&sim_install.step);

    const native_step = b.step("native", "Build the native calculator executable");
    const native_install = b.addInstallArtifact(native_exe, .{});
    native_step.dependOn(&native_install.step);

    const run_sim = b.addRunArtifact(sim_exe);
    run_sim.step.dependOn(&sim_install.step);
    run_sim.addPassthruArgs();
    const run_sim_step = b.step("run-sim", "Build and run the desktop simulator");
    run_sim_step.dependOn(&run_sim.step);

    const run_native = b.addRunArtifact(native_exe);
    run_native.step.dependOn(&native_install.step);
    run_native.addPassthruArgs();
    const run_native_step = b.step("run-native", "Build and run the native calculator");
    run_native_step.dependOn(&run_native.step);

    const run_step = b.step("run", "Build and run the desktop simulator");
    run_step.dependOn(&run_sim.step);

    const memory_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/memory.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const display_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/display/surface.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const ui_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ui.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "sokol", .module = sokol_dep.module("sokol") },
            },
        }),
    });
    const test_step = b.step("test", "Run memory and display tests");
    test_step.dependOn(&b.addRunArtifact(memory_tests).step);
    test_step.dependOn(&b.addRunArtifact(display_tests).step);
    test_step.dependOn(&b.addRunArtifact(ui_tests).step);
}
