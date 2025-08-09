const std = @import("std");
const defs = @import("build_defs.zig");
const Build_options = @import("build.zig").Build_options;

pub fn build_exe(b: *std.Build, build_options: Build_options) void {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = build_options.target,
        .optimize = build_options.optimize,
    });

    const exe = b.addExecutable(.{
        .name = build_options.model_name,
        .root_module = exe_mod,
    });

    // -------------------- params --------------------
    const root_model = b.path("src/model");
    const root_engine = b.path("tflm_tree");

    // -------------------- include paths for the executable --------------------
    exe.addIncludePath(b.path("include"));
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("."));
    includePathToExecutable(
        defs.tflm_tree, //root aka prefix
        exe, // executable
        defs.dir_endings,
    );

    // -------------------- include .cpp files --------------------
    exe.addCSourceFiles(.{
        .root = root_model,
        .files = &.{ "model.cc", "tflm_wrapper.cpp" },
        .flags = defs.tflm_cpp_flags,
    });

    exe.addCSourceFiles(.{
        .root = root_engine,
        .files = defs.micro_cpp_paths,
        .flags = defs.tflm_cpp_flags,
    });

    // -------------------- include .c files --------------------
    exe.addCSourceFiles(.{
        .root = root_engine,
        .files = &.{
            "third_party/kissfft/kiss_fft.c",
            "third_party/kissfft/tools/kiss_fftr.c",
        },
        .flags = defs.tflm_c_flags, // Use C flags, not C++ flags
    });
    exe.linkLibC();
    exe.linkLibCpp();

    b.installArtifact(exe);
}

inline fn includePathToExecutable(
    comptime prefix: []const u8,
    exe: *std.Build.Step.Compile,
    comptime endings: []const []const u8,
) void {
    inline for (endings) |ending| {
        exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = prefix ++ ending });
    }
}
