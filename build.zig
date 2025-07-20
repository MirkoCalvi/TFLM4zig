const std = @import("std");

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
        "-Wno-unused-parameter",
        "-Wno-missing-field-initializers",
        "-Wno-sign-compare",
        "-Wno-unused-function",
        "-Wno-unused-variable",
        "-fno-exceptions",
        "-fno-rtti",
        "-fno-threadsafe-statics",
        "-fmessage-length=0",
        "-fno-delete-null-pointer-checks",
        "-fomit-frame-pointer",
        "-Os",
    };

    exe.addCSourceFiles(.{
        .root = std.Build.LazyPath{ .cwd_relative = tflm_tree },
        .files = &.{
            // core micro
            "tensorflow/lite/micro/micro_allocator.cpp",
            "tensorflow/lite/micro/micro_interpreter.cpp",
            "tensorflow/lite/micro/micro_log.cpp",
            "tensorflow/lite/micro/micro_profiler.cpp",
            "tensorflow/lite/micro/micro_resource_variable.cpp",
            "tensorflow/lite/micro/micro_utils.cpp",
            "tensorflow/lite/micro/recording_micro_allocator.cpp",
            "tensorflow/lite/micro/system_setup.cpp",
            "tensorflow/lite/micro/memory_helpers.cpp",
            "tensorflow/lite/micro/mock_micro_graph.cpp",
            // "tensorflow/lite/micro/micro_string.cpp",
            "tensorflow/lite/micro/micro_time.cpp",
            "tensorflow/lite/micro/debug_log.cpp",
            "tensorflow/lite/micro/micro_op_resolver.cpp",

            // tflite_bridge
            "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.cpp",
            "tensorflow/lite/micro/tflite_bridge/flatbuffer_conversions_bridge.cpp",

            // kernels
            "tensorflow/lite/micro/kernels/activations.cpp",
            "tensorflow/lite/micro/kernels/conv.cpp",
            "tensorflow/lite/micro/kernels/depthwise_conv.cpp",
            "tensorflow/lite/micro/kernels/fully_connected.cpp",
            "tensorflow/lite/micro/kernels/pooling.cpp",
            "tensorflow/lite/micro/kernels/softmax.cpp",
            "tensorflow/lite/micro/kernels/reshape.cpp",
            "tensorflow/lite/micro/kernels/quantize.cpp",
            "tensorflow/lite/micro/kernels/dequantize.cpp",
            "tensorflow/lite/micro/kernels/elementwise.cpp",
            "tensorflow/lite/micro/kernels/logistic.cpp",
            "tensorflow/lite/micro/kernels/concatenation.cpp",
            "tensorflow/lite/micro/kernels/add.cpp",
            "tensorflow/lite/micro/kernels/mul.cpp",
            "tensorflow/lite/micro/kernels/sub.cpp",
            "tensorflow/lite/micro/kernels/pad.cpp",
            "tensorflow/lite/micro/kernels/pack.cpp",
            "tensorflow/lite/micro/kernels/unpack.cpp",
            "tensorflow/lite/micro/kernels/split.cpp",
            "tensorflow/lite/micro/kernels/split_v.cpp",
            "tensorflow/lite/micro/kernels/strided_slice.cpp",
            "tensorflow/lite/micro/kernels/squeeze.cpp",
            "tensorflow/lite/micro/kernels/expand_dims.cpp",
            "tensorflow/lite/micro/kernels/circular_buffer.cpp",
            "tensorflow/lite/micro/kernels/kernel_runner.cpp",
            "tensorflow/lite/micro/kernels/kernel_util.cpp",

            // core tflite
            "tensorflow/lite/core/c/common.cpp",
            "tensorflow/lite/core/api/flatbuffer_conversions.cpp",
            "tensorflow/lite/core/api/tensor_utils.cpp",
            "tensorflow/compiler/mlir/lite/core/api/error_reporter.cpp",
            // "tensorflow/lite/core/api/op_resolver.cpp",

            // kernel utils
            "tensorflow/lite/kernels/internal/quantization_util.cpp",
            "tensorflow/lite/kernels/kernel_util.cpp",

            // flatbuffer utils
            "tensorflow/lite/micro/flatbuffer_utils.cpp",
        },
        .flags = tflm_flags,
    });

    exe.addCSourceFiles(.{
        .root = b.path("src/model"),
        .files = &.{"model.cc"},
        .flags = tflm_flags,
    });

    // USEFUL BUT COMMENTED
    // exe.addCSourceFiles(.{
    //     .root = b.path("src"),
    //     .files = &.{"tflm_wrapper.cpp"},
    //     .flags = tflm_flags,
    // });

    b.installArtifact(exe);
}
