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
    tflm_tree_path: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    isNative: bool,

    pub fn init() Build_options {
        return Build_options{
            .model_name = undefined,
            .build_exe = false,
            .build_lib = false,
            .root_model = "src/model",
            .root_engine = undefined,
            .tflm_tree_path = undefined,
            .target = undefined,
            .optimize = undefined,
            .isNative = true,
        };
    }
};

pub fn build(b: *std.Build) void {
    var build_options = Build_options.init();

    // -------------------------------- TARGET AND OPTIMIZE --------------------------------
    build_options.target = b.standardTargetOptions(.{});
    build_options.optimize = b.standardOptimizeOption(.{});
    // resolved_target may come from std_target or b.resolveTargetQuery(...)
    const resolved_target = build_options.target;

    const host = b.graph.host;
    // conservative native check — compare the important identity fields
    const is_native: bool =
        resolved_target.result.cpu.arch == host.result.cpu.arch and
        resolved_target.result.os.tag == host.result.os.tag and
        resolved_target.result.abi == host.result.abi and
        resolved_target.result.cpu.model == host.result.cpu.model;

    if (is_native) {
        std.debug.print("Target is native (host).\n", .{});
        build_options.root_engine = "tflm_tree";
        build_options.tflm_tree_path = "/home/mirko/Documents/zig/tflm4zig/tflm_tree";
    } else {
        std.debug.print("Target is NOT native. \n", .{});
        build_options.isNative = false;
        build_options.root_engine = "mcu_tflm_tree";
        build_options.tflm_tree_path = "/home/mirko/Documents/zig/tflm4zig/mcu_tflm_tree";
    }

    // Define build options
    build_options.model_name = b.option([]const u8, "model_name", "Name of the model") orelse {
        std.debug.print("❌ Error: -Dmodel_name=\" your_model_name\" is required\n", .{});
        return;
    };

    build_options.build_lib = b.option(bool, "lib", "build the library") orelse false;
    build_options.build_exe = b.option(bool, "exe", "build the executable") orelse false;

    if (build_options.build_lib) {
        std.debug.print("\n Building the lib of {s} ...", .{build_options.model_name});
        lib_builder.build_lib(b, build_options) catch |e| {
            std.debug.print("\n ❌ ERROR ❌: something went wrong:\n    {}\n", .{e});
        };
    }
    if (build_options.build_exe) {
        std.debug.print("\n Building the exe of {s} ...", .{build_options.model_name});
        exe_builder.build_exe(b, build_options) catch |e| {
            std.debug.print("\n ❌ ERROR ❌: something went wrong:\n    {}\n", .{e});
        };
    }
    if (!build_options.build_exe and !build_options.build_lib) {
        std.debug.print("\n❌ add -Dlib and/or -Dexe depending on what you wanto to build\n", .{});
        return;
    }
}

pub fn includePaths(
    prefix: []const u8,
    dest: *std.Build.Step.Compile,
    endings: []const []const u8,
) !void {
    const allocator = std.heap.page_allocator;
    for (endings) |ending| {
        const full_path = try std.fmt.allocPrint(allocator, "{s}{s}", .{ prefix, ending });
        dest.addIncludePath(std.Build.LazyPath{ .cwd_relative = full_path });
        allocator.free(full_path);
    }
}
