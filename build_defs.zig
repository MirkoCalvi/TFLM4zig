const micro_paths = &[_][]const u8{
    // --- Core runtime ---
    "tensorflow/lite/micro/micro_allocation_info.cpp",
    "tensorflow/lite/micro/micro_allocator.cpp",
    "tensorflow/lite/micro/micro_context.cpp",
    "tensorflow/lite/micro/micro_interpreter.cpp",
    "tensorflow/lite/micro/micro_interpreter_context.cpp",
    "tensorflow/lite/micro/micro_log.cpp",
    "tensorflow/lite/micro/micro_mutable_op_resolver.cpp",
    "tensorflow/lite/micro/flatbuffer_utils.cpp",
    "tensorflow/lite/micro/system_setup.cpp",

    // Arena allocators (required by the static arena)
    "tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator.cpp",

    // Bridge for error reporting
    "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.cpp",

    // Common micro-kernel utilities
    "tensorflow/lite/micro/kernels/kernel_util.cpp",

    // --- Your 8 registered operators ---

    // AVERAGE_POOL_2D
    "tensorflow/lite/micro/kernels/pooling_common.cpp",
    "tensorflow/lite/micro/kernels/pooling.cpp",

    // CONCATENATION
    "tensorflow/lite/micro/kernels/concatenation.cpp",

    // CONV_2D
    "tensorflow/lite/micro/kernels/conv_common.cpp",
    "tensorflow/lite/micro/kernels/conv.cpp",

    // DEPTHWISE_CONV_2D
    "tensorflow/lite/micro/kernels/depthwise_conv_common.cpp",
    "tensorflow/lite/micro/kernels/depthwise_conv.cpp",

    // FULLY_CONNECTED
    "tensorflow/lite/micro/kernels/fully_connected_common.cpp",
    "tensorflow/lite/micro/kernels/fully_connected.cpp",

    // MUL
    "tensorflow/lite/micro/kernels/mul_common.cpp",
    "tensorflow/lite/micro/kernels/mul.cpp",

    // PAD
    "tensorflow/lite/micro/kernels/pad_common.cpp",
    "tensorflow/lite/micro/kernels/pad.cpp",

    // SUB
    "tensorflow/lite/micro/kernels/sub_common.cpp",
    "tensorflow/lite/micro/kernels/sub.cpp",
};
