const std = @import("std");
const defs = @import("build_defs.zig");
const Build_options = @import("build.zig").Build_options;

pub fn build_lib(b: *std.Build, build_options: Build_options) void {

    // -------------------- params --------------------
    const root_model = b.path(build_options.root_model);
    const root_engine = b.path(build_options.root_engine);

    // ----------------------------------------------------------------------------------------------------
    //                                        Create the static library
    // ----------------------------------------------------------------------------------------------------

    const lib = b.addStaticLibrary(.{
        .name = build_options.model_name,
        .root_source_file = b.path("src/inference_engine.zig"), // Your main source file
        .target = build_options.target,
        .optimize = build_options.optimize,
    });

    // -------------------- include paths for the library --------------------
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(b.path("."));
    includePathToLib(
        defs.tflm_tree, //root aka prefix
        lib, // library
        defs.dir_endings,
    );

    // -------------------- include .cpp files --------------------
    lib.addCSourceFiles(.{
        .root = root_model,
        .files = &.{ "tflm_wrapper.cpp", "model.cc" },
        .flags = defs.tflm_cpp_flags,
    });

    lib.addCSourceFiles(.{
        .root = root_engine,
        .files = defs.micro_cpp_paths,
        .flags = defs.tflm_cpp_flags,
    });

    // -------------------- include .c files --------------------
    lib.addCSourceFiles(.{
        .root = root_engine,
        .files = &.{
            "third_party/kissfft/kiss_fft.c",
            "third_party/kissfft/tools/kiss_fftr.c",
        },
        .flags = defs.tflm_c_flags, // Use C flags, not C++ flags
    });

    // Link C libraries that your code depends on
    lib.linkLibC();
    // // If you need C++ (TensorFlow Lite is C++)
    lib.linkLibCpp();

    // Install the library
    b.installArtifact(lib);

    // Create a header file installation step
    const install_headers = b.addInstallFile(
        b.path("include/inference_engine.h"),
        "include/inference_engine.h",
    );

    b.getInstallStep().dependOn(&install_headers.step);

    // const lib_cmd = b.addRunArtifact(lib);
    // lib_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     lib_cmd.addArgs(args);
    // }
    // // Optional: Create a build step just for the library
    // const lib_step = b.step("lib", "Build the static library");
    // lib_step.dependOn(&lib_cmd.step);
}

inline fn includePathToLib(
    comptime prefix: []const u8,
    lib: *std.Build.Step.Compile,
    comptime endings: []const []const u8,
) void {
    inline for (endings) |ending| {
        lib.addIncludePath(std.Build.LazyPath{ .cwd_relative = prefix ++ ending });
    }
}
