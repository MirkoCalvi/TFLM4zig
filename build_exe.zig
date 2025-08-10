const std = @import("std");
const build = @import("build.zig");
const defs = @import("build_defs.zig");
const Build_options = @import("build.zig").Build_options;

pub fn build_exe(b: *std.Build, build_options: Build_options) !void {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = build_options.target,
        .optimize = build_options.optimize,
    });

    // -------------------- params --------------------
    const root_model = b.path(build_options.root_model);
    const root_engine = b.path(build_options.root_engine);
    const c_flags = if (build_options.isNative) defs.native_flags.c_flags else defs.MCU_flags.c_flags;
    const cpp_flags = if (build_options.isNative) defs.native_flags.cpp_flags else defs.MCU_flags.cpp_flags;
    const tree_paths = if (build_options.isNative) defs.native_flags.tree_cpp_paths else defs.MCU_flags.tree_cc_paths;

    // ----------------------------------------------------------------------------------------------------
    //                                        Create the executable
    // ----------------------------------------------------------------------------------------------------

    const exe = b.addExecutable(.{
        .name = build_options.model_name,
        .root_module = exe_mod,
    });
    exe.linkLibC();

    // -------------------- include paths for the executable --------------------
    exe.addIncludePath(b.path("include"));
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("."));
    try build.includePaths(
        build_options.tflm_tree_path, //root aka prefix
        exe, // executable
        defs.dir_endings,
    );

    // -------------------- include .cpp files --------------------
    exe.addCSourceFiles(.{
        .root = root_model,
        .files = &.{ "model.cc", "tflm_wrapper.cpp" },
        .flags = cpp_flags,
    });

    exe.addCSourceFiles(.{
        .root = root_engine,
        .files = tree_paths,
        .flags = cpp_flags,
    });

    // -------------------- include .c files --------------------
    exe.addCSourceFiles(.{
        .root = root_engine,
        .files = &.{
            "third_party/kissfft/kiss_fft.c",
            "third_party/kissfft/tools/kiss_fftr.c",
        },
        .flags = c_flags, // Use C flags, not C++ flags
    });

    b.installArtifact(exe);
}
