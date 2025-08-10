const std = @import("std");
const build = @import("build.zig");
const defs = @import("build_defs.zig");
const Build_options = @import("build.zig").Build_options;

pub fn build_lib(b: *std.Build, build_options: Build_options) !void {

    // -------------------- params --------------------
    const root_model = b.path(build_options.root_model);
    const root_engine = b.path(build_options.root_engine);
    const c_flags = if (build_options.isNative) defs.native_flags.c_flags else defs.MCU_flags.c_flags;
    const cpp_flags = if (build_options.isNative) defs.native_flags.cpp_flags else defs.MCU_flags.cpp_flags;
    const tree_files_paths = if (build_options.isNative) defs.native_flags.tree_cpp_paths else defs.MCU_flags.tree_cc_paths;

    // ----------------------------------------------------------------------------------------------------
    //                                        Create the static library
    // ----------------------------------------------------------------------------------------------------

    const lib = b.addStaticLibrary(.{
        .name = build_options.model_name,
        .root_source_file = b.path("src/inference_engine.zig"), // Your main source file
        .target = build_options.target,
        .optimize = build_options.optimize,
    });

    lib.linkLibC();

    // -------------------- include paths for the library --------------------
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(b.path("."));
    try build.includePaths(
        build_options.tflm_tree_path, //root aka prefix
        lib, // library
        defs.dir_endings,
    );

    // -------------------- include .cpp files --------------------
    lib.addCSourceFiles(.{
        .root = root_model,
        .files = &.{ "tflm_wrapper.cpp", "model.cc" },
        .flags = cpp_flags,
    });

    lib.addCSourceFiles(.{
        .root = root_engine,
        .files = tree_files_paths,
        .flags = cpp_flags,
    });

    // -------------------- include .c files --------------------
    lib.addCSourceFiles(.{
        .root = root_engine,
        .files = &.{
            "third_party/kissfft/kiss_fft.c",
            "third_party/kissfft/tools/kiss_fftr.c",
        },
        .flags = c_flags, // Use C flags, not C++ flags
    });

    // Install the library
    b.installArtifact(lib);

    // // Create a header file installation step
    // const install_headers = b.addInstallFile(
    //     b.path("include/inference_engine.h"),
    //     "include/inference_engine.h",
    // );

    // b.getInstallStep().dependOn(&install_headers.step);

    // const lib_cmd = b.addRunArtifact(lib);
    // lib_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     lib_cmd.addArgs(args);
    // }
    // // Optional: Create a build step just for the library
    // const lib_step = b.step("lib", "Build the static library");
    // lib_step.dependOn(&lib_cmd.step);
}
