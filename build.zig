const std = @import("std");
const tflm_def = @import("tflm_def.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "tflm4zig",
        .root_module = exe_mod,
    });

    exe.linkLibCpp();

    exe.addIncludePath(b.path("src"));

    // Use the generated TFLM tree here instead of the original repo
    const tflm_tree = "/home/mirko/Documents/zig/tflm4zig/tflm_tree";
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro" });

    // -- Add all necessary include paths for lite/micro --
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/arena_allocators" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/memory_planner" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/tflite_bridge" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/kernels" });

    // -- Add all necessary include paths for third_party --
    const downloads_path = tflm_tree ++ "/third_party";
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = downloads_path ++ "/flatbuffers/include" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = downloads_path ++ "/gemmlowp" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = downloads_path ++ "/ruy" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = downloads_path ++ "/kissfft" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = downloads_path ++ "/kissfft/tools" });

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

    // -------------------------- recursively collect all .cpp under tflm_tree/tensorflow --------------------------
    var cwd = std.fs.cwd();

    var cpp_files_tflm_tree_tensorflow_list = collectFromDir(b, &cwd, "tflm_tree/tensorflow") catch unreachable;
    const cpp_files_tflm_tree_tensorflow = cpp_files_tflm_tree_tensorflow_list.toOwnedSlice() catch unreachable;
    cpp_files_tflm_tree_tensorflow_list.deinit();
    exe.addCSourceFiles(.{
        .root = std.Build.LazyPath{ .cwd_relative = tflm_tree },
        .files = cpp_files_tflm_tree_tensorflow,
        .flags = tflm_flags,
    });

    // -------------------------- recursively collect all .cpp under tflm_tree/thirth_party --------------------------
    var cpp_files_tflm_tree_thirth_party_list = collectFromDir(b, &cwd, "tflm_tree/third_party") catch unreachable;
    const cpp_files_tflm_tree_thirth_party = cpp_files_tflm_tree_thirth_party_list.toOwnedSlice() catch unreachable;
    cpp_files_tflm_tree_thirth_party_list.deinit();
    exe.addCSourceFiles(.{
        .root = std.Build.LazyPath{ .cwd_relative = tflm_tree },
        .files = cpp_files_tflm_tree_thirth_party,
        .flags = tflm_flags,
    });

    exe.addCSourceFiles(.{
        .root = b.path("src/model"),
        .files = &.{"model.cc"},
        .flags = tflm_flags,
    });

    exe.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"tflm_wrapper.cpp"},
        .flags = tflm_flags,
    });

    b.installArtifact(exe);
}

fn collectFromDir(
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
