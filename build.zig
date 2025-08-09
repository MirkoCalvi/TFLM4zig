const std = @import("std");
const defs = @import("build_defs.zig");
const exe_builder = @import("build_exe.zig");
const lib_builder = @import("build_lib.zig");

pub const Build_options = struct {
    model_name: []const u8,
    build_exe: bool,
    build_lib: bool,
    root_model: []const u8,
    root_engine: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    pub fn init() Build_options {
        return Build_options{
            .model_name = undefined,
            .build_exe = false,
            .build_lib = false,
            .root_model = "src/model",
            .root_engine = "tflm_tree",
            .target = undefined,
            .optimize = undefined,
        };
    }
};

pub fn build(b: *std.Build) void {
    var build_options = Build_options.init();

    build_options.target = b.standardTargetOptions(.{});
    build_options.optimize = b.standardOptimizeOption(.{});
    // Define build options
    build_options.model_name = b.option([]const u8, "model_name", "Name of the model") orelse {
        std.debug.print("❌ Error: -Dmodel_name=\" your_model_name\" is required\n", .{});
        return;
    };

    build_options.build_lib = b.option(bool, "lib", "build the library") orelse false;
    build_options.build_exe = b.option(bool, "exe", "build the executable") orelse false;

    if (build_options.build_lib) {
        std.debug.print("\n Building the lib of {s} ...", .{build_options.model_name});
        lib_builder.build_lib(b, build_options);
    }
    if (build_options.build_exe) {
        std.debug.print("\n Building the exe of {s} ...", .{build_options.model_name});
        exe_builder.build_exe(b, build_options);
    }
    if (!build_options.build_exe and !build_options.build_lib) {
        std.debug.print("\n❌ add -Dlib and/or -Dexe depending on what you wanto to build\n", .{});
        return;
    }
}
