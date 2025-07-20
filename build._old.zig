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
            "tensorflow/lite/micro/micro_allocator.cc",
            "tensorflow/lite/micro/micro_interpreter.cc",
            "tensorflow/lite/micro/micro_log.cc",
            "tensorflow/lite/micro/micro_profiler.cc",
            "tensorflow/lite/micro/micro_resource_variable.cc",
            "tensorflow/lite/micro/micro_utils.cc",
            "tensorflow/lite/micro/recording_micro_allocator.cc",
            "tensorflow/lite/micro/system_setup.cc",
            "tensorflow/lite/micro/memory_helpers.cc",
            "tensorflow/lite/micro/mock_micro_graph.cc",
            "tensorflow/lite/micro/micro_string.cc",
            "tensorflow/lite/micro/micro_time.cc",
            "tensorflow/lite/micro/debug_log.cc",
            "tensorflow/lite/micro/micro_op_resolver.cc",

            // tflite_bridge
            "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.cc",
            "tensorflow/lite/micro/tflite_bridge/flatbuffer_conversions_bridge.cc",

            // kernels
            "tensorflow/lite/micro/kernels/activations.cc",
            "tensorflow/lite/micro/kernels/conv.cc",
            "tensorflow/lite/micro/kernels/depthwise_conv.cc",
            "tensorflow/lite/micro/kernels/fully_connected.cc",
            "tensorflow/lite/micro/kernels/pooling.cc",
            "tensorflow/lite/micro/kernels/softmax.cc",
            "tensorflow/lite/micro/kernels/reshape.cc",
            "tensorflow/lite/micro/kernels/quantize.cc",
            "tensorflow/lite/micro/kernels/dequantize.cc",
            "tensorflow/lite/micro/kernels/elementwise.cc",
            "tensorflow/lite/micro/kernels/logistic.cc",
            "tensorflow/lite/micro/kernels/concatenation.cc",
            "tensorflow/lite/micro/kernels/add.cc",
            "tensorflow/lite/micro/kernels/mul.cc",
            "tensorflow/lite/micro/kernels/sub.cc",
            "tensorflow/lite/micro/kernels/pad.cc",
            "tensorflow/lite/micro/kernels/pack.cc",
            "tensorflow/lite/micro/kernels/unpack.cc",
            "tensorflow/lite/micro/kernels/split.cc",
            "tensorflow/lite/micro/kernels/split_v.cc",
            "tensorflow/lite/micro/kernels/strided_slice.cc",
            "tensorflow/lite/micro/kernels/squeeze.cc",
            "tensorflow/lite/micro/kernels/expand_dims.cc",
            "tensorflow/lite/micro/kernels/circular_buffer.cc",
            "tensorflow/lite/micro/kernels/kernel_runner.cc",
            "tensorflow/lite/micro/kernels/kernel_util.cc",

            // core tflite
            "tensorflow/lite/core/c/common.cc",
            "tensorflow/lite/core/api/flatbuffer_conversions.cc",
            "tensorflow/lite/core/api/tensor_utils.cc",
            "tensorflow/lite/core/api/error_reporter.cc",
            "tensorflow/lite/core/api/op_resolver.cc",

            // kernel utils
            "tensorflow/lite/kernels/internal/quantization_util.cc",
            "tensorflow/lite/kernels/kernel_util.cc",

            // flatbuffer utils
            "tensorflow/lite/micro/flatbuffer_utils.cc",
        },
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
