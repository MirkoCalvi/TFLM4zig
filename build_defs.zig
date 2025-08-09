pub const tflm_tree = "/home/mirko/Documents/zig/tflm4zig/tflm_tree";

pub const dir_endings = &[_][]const u8{
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
    // "/signal",
    // "/signal/micro/kernels",
};

pub const tflm_cpp_flags = &[_][]const u8{
    "-std=c++17", //____________________________ Use the C++17 language standard
    "-DTF_LITE_STATIC_MEMORY", //________________Allocate all tensors and work buffers in one static arena
    "-DTF_LITE_DISABLE_X86_NEON", //_____________Disable x86 NEON optimizations (not available on MCUs)
    "-DTF_LITE_MCU", //__________________________Enable MCU‐specific kernel implementations and memory management
    "-DNDEBUG", //________________________________Disable debug code
    "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK", //__Permit GEMMLOWP to use scalar (non‐SIMD) kernels when needed
    "-Wno-unused-parameter", //__________________Suppress warnings for unused function parameters
    "-Wno-missing-field-initializers", //________Suppress warnings for partially initialized structs
    "-Wno-sign-compare", //______________________Suppress warnings when comparing signed vs unsigned values
    "-Wno-unused-function", //___________________Suppress warnings for static/inline functions that aren’t called
    "-Wno-unused-variable", //___________________Suppress warnings for variables that are declared but never used
    "-fno-exceptions", //________________________Disable C++ exception support (reduces code size)
    "-fno-rtti", //______________________________Disable runtime type information (no typeid/dynamic_cast)
    "-fno-threadsafe-statics", //________________Don’t emit thread-safety guards for function-local statics
    "-fmessage-length=0", //_____________________Don’t wrap diagnostic messages (purely cosmetic)
    "-fno-delete-null-pointer-checks", //________Let optimizer assume null‐pointer dereference is UB
    "-fomit-frame-pointer", //___________________Don’t keep a frame pointer register (saves bytes and a register)
    "-Os", //____________________________________Optimize for smallest code size
    "-ffunction-sections", //____________________Place each function in its own section for linker GC
    "-fdata-sections", //________________________Place each data object in its own section for linker GC
    "-flto", //__________________________________Enable link-time optimization across all translation units
    "-fmerge-all-constants", //__________________Merge identical constants into a single section
    "-fno-common", //____________________________Treat globals as individual symbols to aid dead-code stripping
    // "-nostdlib++", //____________*_______________Don't use standard C++ library
    // "-ffreestanding", //__________*______________Indicate freestanding environment
    // "-fno-use-cxa-atexit", //_______*____________Disable C++ destructor registration
    "-Wl,--gc-sections",
    "-Wl,--strip-unneeded",
    "-Wl,--no-whole-program",
};

pub const MCU_tflm_cpp_flags = &[_][]const u8{
    "-std=c++17",
    "-DTF_LITE_STATIC_MEMORY",
    "-DTF_LITE_DISABLE_X86_NEON",
    "-DTF_LITE_MCU",
    "-DNDEBUG",
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
    "-ffunction-sections",
    "-fdata-sections",
    "-flto",
    "-fmerge-all-constants",
    "-fno-common",
    "-nostdlib++", // Don't use C++ standard library
    "-nostdinc++", // Don't include C++ standard headers
    "-ffreestanding", // Freestanding environment
    "-fno-use-cxa-atexit", // No C++ destructor registration
    // Your custom headers directory
    "-I./include",
    "-Os",
    "-ffunction-sections",
    "-fdata-sections",
};

pub const tflm_c_flags = &[_][]const u8{
    "-std=c99", //_______________________________Use the c99 language standard
    "-DTF_LITE_STATIC_MEMORY", //________________Allocate all tensors and work buffers in one static arena
    "-DTF_LITE_DISABLE_X86_NEON", //_____________Disable x86 NEON optimizations (not available on MCUs)
    "-DTF_LITE_MCU", //__________________________Enable MCU‐specific kernel implementations and memory management
    "-DNDEBUG", //________________________________Disable debug code
    "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK", //__Permit GEMMLOWP to use scalar (non‐SIMD) kernels when needed
    "-Wno-unused-parameter", //__________________Suppress warnings for unused function parameters
    "-Wno-missing-field-initializers", //________Suppress warnings for partially initialized structs
    "-Wno-sign-compare", //______________________Suppress warnings when comparing signed vs unsigned values
    "-Wno-unused-function", //___________________Suppress warnings for static/inline functions that aren’t called
    "-Wno-unused-variable", //___________________Suppress warnings for variables that are declared but never used
    "-fno-exceptions", //________________________Disable C++ exception support (reduces code size)
    "-fno-rtti", //______________________________Disable runtime type information (no typeid/dynamic_cast)
    "-fno-threadsafe-statics", //________________Don’t emit thread-safety guards for function-local statics
    "-fmessage-length=0", //_____________________Don’t wrap diagnostic messages (purely cosmetic)
    "-fno-delete-null-pointer-checks", //________Let optimizer assume null‐pointer dereference is UB
    "-fomit-frame-pointer", //___________________Don’t keep a frame pointer register (saves bytes and a register)
    "-Os", //____________________________________Optimize for smallest code size
    // Section & LTO flags (compile-time)
    "-ffunction-sections", //____________________Place each function in its own section for linker GC
    "-fdata-sections", //________________________Place each data object in its own section for linker GC
    "-flto", //__________________________________Enable link-time optimization across all translation units
    "-fmerge-all-constants", //__________________Merge identical constants into a single section
    "-fno-common", //____________________________Treat globals as individual symbols to aid dead-code stripping
    // "-nostdlib++", //____________*_______________Don't use standard C++ library
    // "-ffreestanding", //__________*______________Indicate freestanding environment
    // "-fno-use-cxa-atexit", //_______*____________Disable C++ destructor registration
    "-Wl,--gc-sections",
    "-Wl,--strip-unneeded",
    "-Wl,--no-whole-program",
};

// Fixed C flags (removed C++ specific flags)
pub const MCU_tflm_c_flags = &[_][]const u8{
    "-std=c99",
    "-DTF_LITE_STATIC_MEMORY",
    "-DTF_LITE_DISABLE_X86_NEON",
    "-DTF_LITE_MCU",
    "-DNDEBUG",
    "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK",
    "-Wno-unused-parameter",
    "-Wno-missing-field-initializers",
    "-Wno-sign-compare",
    "-Wno-unused-function",
    "-Wno-unused-variable",
    "-fmessage-length=0",
    "-fno-delete-null-pointer-checks",
    "-fomit-frame-pointer",
    "-Os",
    "-ffunction-sections",
    "-fdata-sections",
    "-flto",
    "-fmerge-all-constants",
    "-fno-common",
    "-ffreestanding", // Freestanding environment
    // Your custom headers directory
    "-I./include",
    "-Os",
    "-ffunction-sections",
    "-fdata-sections",
};

pub const micro_cpp_paths = &[_][]const u8{

    // --- Core runtime ---
    "tensorflow/lite/micro/micro_allocation_info.cpp",
    "tensorflow/lite/micro/micro_allocator.cpp",
    "tensorflow/lite/micro/micro_context.cpp",
    "tensorflow/lite/micro/micro_interpreter.cpp",
    "tensorflow/lite/micro/micro_interpreter_context.cpp",
    "tensorflow/lite/micro/micro_interpreter_graph.cpp",
    "tensorflow/lite/micro/micro_log.cpp",
    "tensorflow/lite/micro/micro_op_resolver.cpp",
    "tensorflow/lite/micro/micro_profiler.cpp",
    "tensorflow/lite/micro/micro_resource_variable.cpp",
    "tensorflow/lite/micro/micro_time.cpp",
    "tensorflow/lite/micro/micro_utils.cpp",
    "tensorflow/lite/micro/flatbuffer_utils.cpp",
    "tensorflow/lite/micro/system_setup.cpp",
    "tensorflow/lite/micro/debug_log.cpp",
    "tensorflow/lite/micro/fake_micro_context.cpp",
    "tensorflow/lite/micro/hexdump.cpp",
    "tensorflow/lite/micro/memory_helpers.cpp",
    "tensorflow/lite/micro/recording_micro_allocator.cpp",
    "tensorflow/lite/micro/test_helper_custom_ops.cpp",
    "tensorflow/lite/micro/test_helpers.cpp",
    "tensorflow/lite/micro/mock_micro_graph.cpp",

    // Arena allocators
    "tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator.cpp",
    "tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator.cpp",

    // Memory planners
    "tensorflow/lite/micro/memory_planner/greedy_memory_planner.cpp",
    "tensorflow/lite/micro/memory_planner/linear_memory_planner.cpp",
    "tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim.cpp",

    // Bridge files
    "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.cpp",
    "tensorflow/lite/micro/tflite_bridge/flatbuffer_conversions_bridge.cpp",

    // Core API (from compiler/mlir/lite/core/api)
    "tensorflow/compiler/mlir/lite/core/api/error_reporter.cpp",

    // Schema utilities
    "tensorflow/compiler/mlir/lite/schema/schema_utils.cpp",

    // TensorFlow Lite core files
    "tensorflow/lite/core/api/flatbuffer_conversions.cpp",
    "tensorflow/lite/core/api/tensor_utils.cpp",
    "tensorflow/lite/core/c/common.cpp",

    // Internal utilities
    "tensorflow/lite/kernels/internal/common.cpp",
    "tensorflow/lite/kernels/internal/portable_tensor_utils.cpp",
    "tensorflow/lite/kernels/internal/quantization_util.cpp",
    "tensorflow/lite/kernels/internal/reference/comparisons.cpp",
    "tensorflow/lite/kernels/internal/reference/portable_tensor_utils.cpp",
    "tensorflow/lite/kernels/internal/runtime_shape.cpp",
    "tensorflow/lite/kernels/internal/tensor_ctypes.cpp",
    "tensorflow/lite/kernels/internal/tensor_utils.cpp",
    "tensorflow/lite/kernels/kernel_util.cpp",

    // Micro kernels utilities
    "tensorflow/lite/micro/kernels/kernel_util.cpp",
    "tensorflow/lite/micro/kernels/kernel_runner.cpp",
    "tensorflow/lite/micro/kernels/micro_tensor_utils.cpp",

    // --- ADD ---
    "tensorflow/lite/micro/kernels/add_common.cpp",
    "tensorflow/lite/micro/kernels/add.cpp",

    // --- CONV_2D ---
    "tensorflow/lite/micro/kernels/conv_common.cpp",
    "tensorflow/lite/micro/kernels/conv.cpp",

    // --- DEPTHWISE_CONV_2D ---
    "tensorflow/lite/micro/kernels/depthwise_conv_common.cpp",
    "tensorflow/lite/micro/kernels/depthwise_conv.cpp",

    // --- FULLY_CONNECTED ---
    "tensorflow/lite/micro/kernels/fully_connected_common.cpp",
    "tensorflow/lite/micro/kernels/fully_connected.cpp",

    // --- MUL ---
    "tensorflow/lite/micro/kernels/mul_common.cpp",
    "tensorflow/lite/micro/kernels/mul.cpp",

    // --- PAD ---
    "tensorflow/lite/micro/kernels/pad_common.cpp",
    "tensorflow/lite/micro/kernels/pad.cpp",

    // --- SUB ---
    "tensorflow/lite/micro/kernels/sub_common.cpp",
    "tensorflow/lite/micro/kernels/sub.cpp",
};

// Separate linker flags to be used during linking phase
pub const tflm_link_flags = &[_][]const u8{
    "-Wl,--gc-sections",
    "-Wl,--strip-unneeded",
    "-Wl,--no-whole-program",
};
