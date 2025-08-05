const std = @import("std");

pub fn build(b: *std.Build) void {
    // Define build options
    const build_options = b.addOptions();
    const model_name = b.option([]const u8, "model_name", "Name of the model") orelse {
        std.debug.print("❌ Error: -Dmodel_name=\" your_model_name\" is required\n", .{});
        return;
    };
    build_options.addOption([]const u8, "model_name", model_name);

    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const exe = b.addExecutable(.{
        .name = "tflm4zig",
        .root_module = exe_mod,
    });

    exe_mod.addOptions("build_options", build_options);
    exe.linkLibCpp();

    // -------------------- params --------------------
    const root_model_path = b.fmt("src/models/{s}", .{model_name});
    const root_model = b.path(root_model_path);

    const tflm_tree = "/home/mirko/Documents/zig/tflm4zig/tflm_tree";
    const dir_endings = &[_][]const u8{
        "",
        "/tensorflow",
        "/tensorflow/lite",
        "/tensorflow/lite/micro",
        // -- Add all necessary include paths for lite/micro --
        "/tensorflow/lite/micro/arena_allocators",
        "/tensorflow/lite/micro/memory_planner",
        "/tensorflow/lite/micro/tflite_bridge",
        "/tensorflow/lite/micro/kernels",
        // -- Add all necessary include paths for third_party --
        "/third_party/flatbuffers/include",
        "/third_party/gemmlowp",
        "/third_party/ruy",
        "/third_party/kissfft",
        "/third_party/kissfft/tools",
        // -- Add all necessary include paths for signal --
        "/signal",
        "/signal/micro/kernels",
    };
    const tflm_flags = &[_][]const u8{
        "-std=c++17",
        "-DTF_LITE_STATIC_MEMORY",
        "-DTF_LITE_DISABLE_X86_NEON",
        "-DTF_LITE_MCU",
        "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK",
        // "-Wno-unused-parameter",
        // "-Wno-missing-field-initializers",
        // "-Wno-sign-compare",
        // "-Wno-unused-function",
        // "-Wno-unused-variable",
        // "-fno-exceptions",
        // "-fno-rtti",
        // "-fno-threadsafe-statics",
        // "-fmessage-length=0",
        // "-fno-delete-null-pointer-checks",
        // "-fomit-frame-pointer",
        // "-Os",
    };

    // -------------------- include paths for the executable --------------------
    exe.addIncludePath(b.path("src"));
    includePathToExecutable(
        tflm_tree, //root aka prefix
        exe, // executable
        dir_endings,
    );

    // -------------------------- recursively collect all .cpp under tflm_tree/tensorflow --------------------------
    addCSourceFilesToExecutable(
        b,
        exe,
        tflm_tree, // root
        &.{
            "tflm_tree/tensorflow", // recursively collect all .cpp under tflm_tree/tensorflow
            "tflm_tree/third_party", // recursively collect all .cpp under tflm_tree/thirth_party
            "tflm_tree/signal", // recursively collect all .cpp under tflm_tree/signal
        },
        tflm_flags,
    );
    exe.addCSourceFiles(.{
        .root = root_model,
        .files = &.{"model.cc"},
        .flags = tflm_flags,
    });

    exe.addCSourceFiles(.{
        .root = root_model,
        .files = &.{"tflm_wrapper.cpp"},
        .flags = tflm_flags,
    });

    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // ----------------------------------------------------------------------------------------------------
    //                                        Create the static library
    // ----------------------------------------------------------------------------------------------------

    const lib = b.addStaticLibrary(.{
        .name = "tflm_inference",
        .root_source_file = b.path("src/inference_engine.zig"), // Your main source file
        .target = target,
        .optimize = .ReleaseSmall,
    });

    // -------------------- include paths for the library --------------------
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(b.path("."));
    includePathToLib(
        tflm_tree, //root aka prefix
        lib, // library
        dir_endings,
    );

    // -------------------------- recursively collect all .cpp under tflm_tree/tensorflow --------------------------
    addCSourceFilesToLib(
        b,
        lib,
        tflm_tree, // root
        &.{
            "tflm_tree/tensorflow", // recursively collect all .cpp under tflm_tree/tensorflow
            "tflm_tree/third_party", // recursively collect all .cpp under tflm_tree/thirth_party
            "tflm_tree/signal", // recursively collect all .cpp under tflm_tree/signal
        },
        tflm_flags,
    );
    lib.addCSourceFiles(.{
        .root = root_model,
        .files = &.{"model.cc"},
        .flags = tflm_flags,
    });
    lib.addCSourceFiles(.{
        .root = root_model,
        .files = &.{"tflm_wrapper.cpp"},
        .flags = tflm_flags,
    });

    // Link C libraries that your code depends on
    lib.linkLibC();
    // If you need C++ (TensorFlow Lite is C++)
    lib.linkLibCpp();

    // Install the library
    b.installArtifact(lib);

    // Create a header file installation step
    const install_headers = b.addInstallFile(
        b.path("include/inference_engine.h"),
        "include/inference_engine.h",
    );
    b.getInstallStep().dependOn(&install_headers.step);

    // Optional: Create a build step just for the library
    const lib_step = b.step("lib", "Build the static library");
    lib_step.dependOn(&lib.step);
}

inline fn collectFromDir(
    b: *std.Build,
    cwd: *std.fs.Dir,
    prefix: []const u8,
) !std.ArrayList([]const u8) {
    var root_dir = cwd.openDir(prefix, .{ .iterate = true }) catch unreachable;
    var list = std.ArrayList([]const u8).init(b.allocator);
    std.debug.print("\n ------ START COLLECTING ------", .{});
    try collect(b, root_dir, prefix, &list);
    std.debug.print("\n ------ STOP COLLECTING ------", .{});
    root_dir.close(); // Only close root_dir, not cwd fs!
    return list;
}

fn collect(
    b: *std.Build,
    dir: std.fs.Dir,
    prefix: []const u8,
    list: *std.ArrayList([]const u8),
) !void {
    var it = dir.iterate();
    std.debug.print("\nCollecting files from: {s}", .{prefix});
    while (true) {
        const entry = try it.next();
        if (entry) |e| {
            const name = e.name;

            // Skip "." and ".."
            if (std.mem.eql(u8, name, ".") or std.mem.eql(u8, name, "..")) {
                continue;
            }

            // Skip non-UTF-8 names (shouldn't happen on Linux, but just in case)
            if (!std.unicode.utf8ValidateSlice(name)) {
                std.debug.print("\nSkipping invalid UTF-8 entry: {s}", .{name});
                continue;
            }

            const full = std.fmt.allocPrint(b.allocator, "{s}/{s}", .{ prefix, name }) catch continue;
            if (e.kind == .file and std.mem.endsWith(u8, name, ".cpp")) {
                const slash_index = std.mem.indexOf(u8, full, "/") orelse 0;
                const rel = full[slash_index + 1 ..];
                std.debug.print("\nAdding: {s}", .{rel});

                const new_path = try b.allocator.dupe(u8, rel);

                try list.append(new_path);
            } else if (e.kind == .directory) {
                var sub = dir.openDir(name, .{ .iterate = true }) catch {
                    b.allocator.free(full);
                    continue;
                };
                try collect(b, sub, full, list);
                sub.close();
            }
            b.allocator.free(full);
        } else {
            break; // No more entries
        }
    }
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

inline fn includePathToLib(
    comptime prefix: []const u8,
    lib: *std.Build.Step.Compile,
    comptime endings: []const []const u8,
) void {
    inline for (endings) |ending| {
        lib.addIncludePath(std.Build.LazyPath{ .cwd_relative = prefix ++ ending });
    }
}

inline fn addCSourceFilesToExecutable(
    b: *std.Build,
    exe: *std.Build.Step.Compile,
    comptime root: []const u8,
    comptime dir: []const []const u8,
    comptime flags: []const []const u8,
) void {
    var cwd = std.fs.cwd();
    inline for (dir) |d| {
        var cpp_files_list = collectFromDir(b, &cwd, d) catch unreachable;
        const cpp_files = cpp_files_list.toOwnedSlice() catch unreachable;
        cpp_files_list.deinit();
        exe.addCSourceFiles(.{
            .root = std.Build.LazyPath{ .cwd_relative = root },
            .files = cpp_files,
            .flags = flags,
        });
    }
}

fn addCSourceFilesToLib(
    b: *std.Build,
    lib: *std.Build.Step.Compile,
    comptime root: []const u8,
    comptime dir: []const []const u8,
    comptime flags: []const []const u8,
) void {
    var cwd = std.fs.cwd();
    inline for (dir) |d| {
        var cpp_files_list = collectFromDir(b, &cwd, d) catch unreachable;
        const cpp_files = cpp_files_list.toOwnedSlice() catch unreachable;
        cpp_files_list.deinit();
        lib.addCSourceFiles(.{
            .root = std.Build.LazyPath{ .cwd_relative = root },
            .files = cpp_files,
            .flags = flags,
        });
    }
}
