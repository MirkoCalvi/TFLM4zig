const std = @import("std");

// ----- /tflm4zig/tflm_tree/tensorflow/lite/micro
pub const micro_cpp_files = &.{
    "debug_log.cpp",
    "fake_micro_context.cpp",
    "flatbuffer_utils.cpp",
    "hexdump.cpp",
    "memory_helpers.cpp",
    "micro_allocation_info.cpp",
    "micro_allocator.cpp",
    "micro_context.cpp",
    "micro_interpreter.cpp",
    "micro_interpreter_context.cpp",
    "micro_interpreter_graph.cpp",
    "micro_log.cpp",
    "micro_op_resolver.cpp",
    "micro_profiler.cpp",
    "micro_resource_variable.cpp",
    "micro_time.cpp",
    "micro_utils.cpp",
    "mock_micro_graph.cpp",
    "recording_micro_allocator.cpp",
    "system_setup.cpp",
    "test_helper_custom_ops.cpp",
    "test_helpers.cpp",
};

// ----- /tflm4zig/tflm_tree/tensorflow/lite/micro/kernels
pub const micro_kernels_cpp_files = &.{
    "activations.cpp",
    "activations_common.cpp",
    "add.cpp",
    "add_common.cpp",
    "add_n.cpp",
    "arg_min_max.cpp",
    "assign_variable.cpp",
    "batch_matmul.cpp",
    "batch_matmul_common.cpp",
    "batch_to_space_nd.cpp",
    "broadcast_args.cpp",
    "broadcast_to.cpp",
    "call_once.cpp",
    "cast.cpp",
    "ceil.cpp",
    "circular_buffer.cpp",
    "circular_buffer_common.cpp",
    "comparisons.cpp",
    "concatenation.cpp",
    "conv.cpp",
    "conv_common.cpp",
    "cumsum.cpp",
    "decompress.cpp",
    "decompress_common.cpp",
    "depth_to_space.cpp",
    "depthwise_conv.cpp",
    "depthwise_conv_common.cpp",
    "dequantize.cpp",
    "dequantize_common.cpp",
    "detection_postprocess.cpp",
    "div.cpp",
    "elementwise.cpp",
    "elu.cpp",
    "embedding_lookup.cpp",
    "ethosu.cpp",
    "expand_dims.cpp",
    "exp.cpp",
    "fill.cpp",
    "floor.cpp",
    "floor_div.cpp",
    "floor_mod.cpp",
    "gather.cpp",
    "gather_nd.cpp",
    "hard_swish.cpp",
    "hard_swish_common.cpp",
    "kernel_runner.cpp",
    "kernel_util.cpp",
    "leaky_relu.cpp",
    "leaky_relu_common.cpp",
    "logical.cpp",
    "logical_common.cpp",
    "log_softmax.cpp",
    "l2_pool_2d.cpp",
    "l2norm.cpp",
    "lstm_eval.cpp",
    "lstm_eval_common.cpp",
    "maximum_minimum.cpp",
    "micro_tensor_utils.cpp",
    "mirror_pad.cpp",
    "mul.cpp",
    "mul_common.cpp",
    "neg.cpp",
    "pad.cpp",
    "pad_common.cpp",
    "pooling.cpp",
    "pooling_common.cpp",
    "prelu.cpp",
    "prelu_common.cpp",
    "quantize.cpp",
    "quantize_common.cpp",
    "read_variable.cpp",
    "reduce.cpp",
    "reduce_common.cpp",
    "resize_bilinear.cpp",
    "resize_nearest_neighbor.cpp",
    "reverse.cpp",
    "round.cpp",
    "select.cpp",
    "shape.cpp",
    "slice.cpp",
    "softmax.cpp",
    "softmax_common.cpp",
    "space_to_batch_nd.cpp",
    "space_to_depth.cpp",
    "split.cpp",
    "split_v.cpp",
    "squared_difference.cpp",
    "strided_slice.cpp",
    "strided_slice_common.cpp",
    "svdf.cpp",
    "svdf_common.cpp",
    "tanh.cpp",
    "transpose.cpp",
    "transpose_common.cpp",
    "transpose_conv.cpp",
    "unidirectional_sequence_lstm.cpp",
    "var_handle.cpp",
    "while.cpp",
    "zeros_like.cpp",
};

pub const micro_bridge_cpp_files = &.{
    "tflite_bridge/micro_error_reporter.cpp",
    "tflite_bridge/flatbuffer_conversions_bridge.cpp",
};

pub const micro_arena_allocator_cpp_files = &.{
    "non_persistent_arena_buffer_allocator.cpp",
    "persistent_arena_buffer_allocator.cpp",
    "recording_single_arena_buffer_allocator.cpp",
    "single_arena_buffer_allocator.cpp",
};

// // ************ importing tensorflow/lite/ ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/" },
//     .files = &.{
//         // core tflite
//         "core/c/common.cpp",
//         "core/api/flatbuffer_conversions.cpp",
//         "core/api/tensor_utils.cpp",
//         "tensorflow/compiler/mlir/lite/core/api/error_reporter.cpp",
//         // "core/api/op_resolver.cpp",

//         // kernel utils
//         "kernels/internal/quantization_util.cpp",
//         "kernels/kernel_util.cpp",
//     },
//     .flags = tflm_flags,
// });

// // ************ importing tensorflow/lite/micro/ ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/" },
//     .files = tflm_def.micro_cpp_files,
//     .flags = tflm_flags,
// });

// // ************ importing tensorflow/lite/micro/kernels ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/kernels/" },
//     .files = tflm_def.micro_kernels_cpp_files,
//     .flags = tflm_flags,
// });

// // ************ importing tensorflow/lite/micro/tflite_bridge ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/tflite_bridge/" },
//     .files = tflm_def.micro_bridge_cpp_files,
//     .flags = tflm_flags,
// });

// // ************ importing tensorflow/lite/micro/arena_allocator ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/arena_allocator/" },
//     .files = tflm_def.micro_arena_allocator_cpp_files,
//     .flags = tflm_flags,
// });

// // ************ importing tensorflow/lite/micro/memory_planner ************
// exe.addCSourceFiles(.{
//     .root = std.Build.LazyPath{ .cwd_relative = tflm_tree ++ "/tensorflow/lite/micro/memory_planner/" },
//     .files = tflm_def.micro_arena_allocator_cpp_files,
//     .flags = tflm_flags,
// });

// std.debug.print("\nCollected {} files:\n", .{cpp_files.len});
// for (cpp_files) |file| {
//     std.debug.print("  - {s}\n", .{file});
// }
