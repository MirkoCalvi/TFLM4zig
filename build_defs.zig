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

// Separate linker flags to be used during linking phase
pub const tflm_link_flags = &[_][]const u8{
    "-Wl,--gc-sections",
    "-Wl,--strip-unneeded",
    "-Wl,--no-whole-program",
};

// -------------------------------------------------------
// ------------------------ FLAGS ------------------------
// -------------------------------------------------------

pub const native_flags = struct {
    pub const c_flags = &[_][]const u8{
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

    pub const cpp_flags = &[_][]const u8{
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

    pub const tree_cpp_paths = &[_][]const u8{

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
};

pub const MCU_flags = struct {
    pub const c_flags = &[_][]const u8{
        "-std=c99",
        "-DTF_LITE_MCU",
        "-DTF_LITE_STATIC_MEMORY",
        "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK",
        // // // Define missing floating point constants
        // // "-DFP_NAN=0",
        // // "-DFP_INFINITE=1",
        // // "-DFP_ZERO=2",
        // // "-DFP_SUBNORMAL=3",
        // // "-DFP_NORMAL=4",
        // // "-DNULL=((void*)0)",
        // // // Include our custom headers first
        // // // "-include",
        // // // "stdlib.h",
        // // // Force use of minimal math
        // // "-D_GNU_SOURCE",
        // "-D__STDC_VERSION__=199901L",
        // Suppress warnings for large codebase
        "-Wno-unused-parameter",
        "-Wno-missing-field-initializers",
        "-Wno-sign-compare",
        "-Wno-unused-function",
        "-Wno-unused-variable",
        "-Wno-implicit-function-declaration",
    };

    pub const cpp_flags = &[_][]const u8{
        "-std=c++17",
        "-mcpu=cortex-m7",
        "-mfpu=fpv5-d16",
        "-DARMCM7_DP",
        // "-std=c++17",
        "-DTF_LITE_MCU",
        "-DTF_LITE_STATIC_MEMORY",
        "-DTF_LITE_MCU_DEBUG_LOG",
        "-mthumb",
        "-funsigned-char",
        // "-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK",
        // Include minimal C++ runtime first
        // "-include",
        // "minimal_cpp_runtime.h",
        // Define missing floating point constants
        // "-DFP_NAN=0",
        // "-DFP_INFINITE=1",
        // "-DFP_ZERO=2",
        // "-DFP_SUBNORMAL=3",
        // "-DFP_NORMAL=4",
        // "-DNULL=nullptr",
        // // // Disable full C++ standard library
        // // "-nostdlib++",
        // // "-nostdinc++",
        // // Avoid problematic C++ standard library features
        // "-DFLATBUFFERS_LOCALE_INDEPENDENT=1",
        // "-DFLATBUFFERS_USE_STD_SPAN=0",
        // "-D_LIBCPP_HAS_NO_LOCALIZATION=1",
        // "-D_LIBCPP_HAS_NO_THREADS=1",
        // "-D_LIBCPP_HAS_NO_WIDE_CHARACTERS=1",
        // Essential C++ flags for embedded
        "-fno-exceptions",
        "-fno-rtti",
        "-fno-threadsafe-statics",
        "-fno-use-cxa-atexit",
        // Suppress warnings
        "-Wno-unused-parameter",
        "-Wno-missing-field-initializers",
        "-Wno-sign-compare",
        "-Wno-unused-function",
        "-Wno-unused-variable",
        "-Wno-implicit-function-declaration",
    };
    pub const tree_cc_paths = &[_][]const u8{

        // --- Core runtime ---
        "tensorflow/lite/micro/micro_allocation_info.cc",
        "tensorflow/lite/micro/micro_allocator.cc",
        "tensorflow/lite/micro/micro_context.cc",
        "tensorflow/lite/micro/micro_interpreter.cc",
        "tensorflow/lite/micro/micro_interpreter_context.cc",
        "tensorflow/lite/micro/micro_interpreter_graph.cc",
        "tensorflow/lite/micro/micro_log.cc",
        "tensorflow/lite/micro/micro_op_resolver.cc",
        "tensorflow/lite/micro/micro_profiler.cc",
        "tensorflow/lite/micro/micro_resource_variable.cc",
        // "tensorflow/lite/micro/micro_time.cc",
        "tensorflow/lite/micro/micro_utils.cc",
        "tensorflow/lite/micro/flatbuffer_utils.cc",
        "tensorflow/lite/micro/system_setup.cc",
        // "tensorflow/lite/micro/debug_log.cc",
        "tensorflow/lite/micro/fake_micro_context.cc",
        "tensorflow/lite/micro/hexdump.cc",
        "tensorflow/lite/micro/memory_helpers.cc",
        "tensorflow/lite/micro/recording_micro_allocator.cc",
        "tensorflow/lite/micro/test_helper_custom_ops.cc",
        "tensorflow/lite/micro/test_helpers.cc",
        "tensorflow/lite/micro/mock_micro_graph.cc",

        // Arena allocators
        "tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator.cc",
        "tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator.cc",
        "tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator.cc",
        "tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator.cc",

        // Memory planners
        "tensorflow/lite/micro/memory_planner/greedy_memory_planner.cc",
        "tensorflow/lite/micro/memory_planner/linear_memory_planner.cc",
        "tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim.cc",

        // Bridge files
        "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.cc",
        "tensorflow/lite/micro/tflite_bridge/flatbuffer_conversions_bridge.cc",

        // Core API (from compiler/mlir/lite/core/api)
        "tensorflow/compiler/mlir/lite/core/api/error_reporter.cc",

        // Schema utilities
        "tensorflow/compiler/mlir/lite/schema/schema_utils.cc",

        // TensorFlow Lite core files
        "tensorflow/lite/core/api/flatbuffer_conversions.cc",
        "tensorflow/lite/core/api/tensor_utils.cc",
        "tensorflow/lite/core/c/common.cc",

        // Internal utilities
        "tensorflow/lite/kernels/internal/common.cc",
        "tensorflow/lite/kernels/internal/portable_tensor_utils.cc",
        "tensorflow/lite/kernels/internal/quantization_util.cc",
        "tensorflow/lite/kernels/internal/reference/comparisons.cc",
        "tensorflow/lite/kernels/internal/reference/portable_tensor_utils.cc",
        "tensorflow/lite/kernels/internal/runtime_shape.cc",
        "tensorflow/lite/kernels/internal/tensor_ctypes.cc",
        "tensorflow/lite/kernels/internal/tensor_utils.cc",
        "tensorflow/lite/kernels/kernel_util.cc",

        // Micro kernels utilities
        "tensorflow/lite/micro/kernels/kernel_util.cc",
        "tensorflow/lite/micro/kernels/kernel_runner.cc",
        "tensorflow/lite/micro/kernels/micro_tensor_utils.cc",

        // --- ADD ---
        "tensorflow/lite/micro/kernels/add_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/add.cc",

        // --- CONV_2D ---
        "tensorflow/lite/micro/kernels/conv_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/conv.cc",

        // --- DEPTHWISE_CONV_2D ---
        "tensorflow/lite/micro/kernels/depthwise_conv_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/depthwise_conv.cc",

        // --- FULLY_CONNECTED ---
        "tensorflow/lite/micro/kernels/fully_connected_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/fully_connected.cc",

        // --- MUL ---
        "tensorflow/lite/micro/kernels/mul_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/mul.cc",

        // --- PAD ---
        "tensorflow/lite/micro/kernels/pad_common.cc",
        "tensorflow/lite/micro/kernels/cmsis_nn/pad.cc",

        // --- SUB ---
        "tensorflow/lite/micro/kernels/sub_common.cc",
        "tensorflow/lite/micro/kernels/sub.cc",
    };
};
