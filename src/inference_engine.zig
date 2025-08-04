const build_options = @import("build_options");

const cc_model = @cImport({
    @cInclude("models/mob_net/model.h");
});

const std = @import("std");
const tflm = @import("tflm.zig");

pub const Engine = struct {
    interpreter: tflm.TFLMInterpreter,
    arena_buffer: []u8, // raw bytes for arena
    arena_allocator: std.heap.ArenaAllocator,

    /// One-time initializer. Call this once at program startup.
    pub fn init(arena_size: usize) !*Engine {

        // Build a  &[u8] view over your model
        const data = cc_model.tfl__model_tflite[0..230912];

        // carve out a big byte buffer
        const arena_buf = std.heap.page_allocator.alloc(u8, arena_size) catch |err| {
            std.debug.print("OOM allocating arena buffer: {}\n", .{err});
            return err;
        };

        // an ArenaAllocator wrapper around that buffer
        var fixed = std.heap.FixedBufferAllocator.init(arena_buf);
        var arena = std.heap.ArenaAllocator.init(fixed.allocator());
        const alloc = arena.allocator();

        std.debug.print("\n+++++++++ TFLMInterpreter initialization\n", .{});

        const interp = try tflm.TFLMInterpreter.init(alloc, arena_size, data);

        // allocate Engine itself from the general-purpose allocator
        // so the pointer is stable
        const e_ptr = try alloc.create(Engine);
        e_ptr.* = Engine{
            .interpreter = interp,
            .arena_buffer = arena_buf,
            .arena_allocator = arena,
        };
        return e_ptr;
    }

    /// Destroy/free the Engine
    pub fn deinit(self: *Engine) void {
        self.interpreter.deinit();
        // give back the raw buffer
        std.heap.page_allocator.free(self.arena_buffer);
        // no need to deinit the ArenaAllocator itself
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
pub export fn inference_init(arena_size: usize) EngineHandle {
    if (global_engine) |h| return h;
    global_engine = Engine.init(arena_size) catch |err| {
        std.debug.print("Failed to initialize inference engine: {}\n", .{err});
        return null;
    };
    return global_engine;
}

pub export fn inference_deinit() void {
    if (global_engine) |h| {
        h.deinit();
        global_engine = null;
    }
}

pub export fn inference_input_buffer_ptr() [*]f32 {
    const eng = global_engine orelse @panic("Engine not initialized");
    const slice = eng.interpreter.getInputBuffer(0);
    return slice.ptr;
}

pub export fn inference_input_len() usize {
    const eng = global_engine orelse @panic("Engine not initialized");
    return eng.interpreter.getInputBuffer(0).len;
}

pub export fn inference_output_buffer_ptr() [*]f32 {
    const eng = global_engine orelse @panic("Engine not initialized");
    const slice = eng.interpreter.getOutputBuffer(0);
    return slice.ptr;
}

pub export fn inference_output_len() usize {
    const eng = global_engine orelse @panic("Engine not initialized");
    return eng.interpreter.getOutputBuffer(0).len;
}

pub export fn inference_invoke() i8 {
    const eng = global_engine orelse @panic("Engine not initialized");
    eng.interpreter.invoke() catch return -1;

    // return 0 on success, -1 on failure
    return 0;
}
