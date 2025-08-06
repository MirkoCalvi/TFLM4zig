const build_options = @import("build_options");
const cc_model = @cImport({
    @cInclude("models/dummy/model.h");
});
const std = @import("std");
const tflm = @import("tflm.zig");

pub const Engine = struct {
    interpreter: tflm.TFLMInterpreter,
    allocator: std.mem.Allocator,

    /// One-time initializer. Call this once at program startup.
    pub fn init(arena_size: usize) !*Engine {
        // Build a &[u8] view over your model
        const data = cc_model.tfl__model_tflite[0..8220];

        std.debug.print("\n+++++++++ TFLMInterpreter initialization\n", .{});

        // Use page allocator directly like your working example
        const allocator = std.heap.c_allocator;

        // Initialize interpreter as a value (not pointer) like your working example
        var interpreter = tflm.TFLMInterpreter.init(allocator, arena_size, data) catch |err| {
            return err;
        };

        // Allocate Engine itself from the general-purpose allocator
        const e_ptr = allocator.create(Engine) catch |err| {
            // Clean up on failure
            interpreter.deinit();
            return err;
        };

        e_ptr.* = Engine{
            .interpreter = interpreter,
            .allocator = allocator,
        };

        return e_ptr;
    }

    /// Destroy/free the Engine
    pub fn deinit(self: *Engine) void {
        self.interpreter.deinit();
        // Free the Engine struct itself
        self.allocator.destroy(self);
    }
};

//---------------------------------------------------------------------------
// C API exports
//---------------------------------------------------------------------------
var global_engine: ?*Engine = null;

/// Opaque handle
pub const EngineHandle = ?*Engine;

/// Errors returned by init
pub const InitError = error{
    TFLMInterpreterError,
    CreateFailed,
};

/// export functions with C ABI
pub export fn inference_init(arena_size: usize) callconv(.C) EngineHandle {
    if (global_engine) |h| return h;

    global_engine = Engine.init(arena_size) catch |err| {
        std.debug.print("Failed to initialize inference engine: {}\n", .{err});
        return null;
    };

    return global_engine;
}

pub export fn inference_deinit() callconv(.C) void {
    if (global_engine) |h| {
        h.deinit();
        global_engine = null;
    }
}

pub export fn inference_input_buffer_ptr() callconv(.C) [*]f32 {
    const eng = global_engine orelse @panic("Engine not initialized");
    const slice = eng.interpreter.getInputBuffer(0);
    return slice.ptr;
}

pub export fn inference_input_len() callconv(.C) usize {
    const eng = global_engine orelse @panic("Engine not initialized");
    return eng.interpreter.getInputBuffer(0).len;
}

pub export fn inference_output_buffer_ptr() callconv(.C) [*]f32 {
    const eng = global_engine orelse @panic("Engine not initialized");
    const slice = eng.interpreter.getOutputBuffer(0);
    return slice.ptr;
}

pub export fn inference_output_len() callconv(.C) usize {
    const eng = global_engine orelse @panic("Engine not initialized");
    return eng.interpreter.getOutputBuffer(0).len;
}

pub export fn inference_invoke() callconv(.C) i8 {
    const eng = global_engine orelse @panic("Engine not initialized");
    eng.interpreter.invoke() catch return -1;
    return 0;
}
