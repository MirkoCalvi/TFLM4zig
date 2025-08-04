const build_options = @import("build_options");

const cc_model = @cImport({
    @cInclude("models/mobilenet_v2_imagenette/model.h");
});

const std = @import("std");
const tflm = @import("tflm.zig");

pub const Engine = struct {
    interpreter: tflm.TFLMInterpreter,
    allocator_storage: std.heap.GeneralPurposeAllocator(.{}),
    allocator: std.mem.Allocator,

    /// One-time initializer. Call this once at program startup.
    pub fn init(arena_size: usize) Engine {
        // Build a  &[u8] view over your model
        const data = cc_model.tfl__model_tflite[0..cc_model.tfl__model_tflite_len];

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const alloc = gpa.allocator();
        std.debug.print("\n+++++++++ TFLMInterpreter initialization\n", .{});
        const interp = tflm.TFLMInterpreter.init(alloc, arena_size, data) catch {
            gpa.deinit();
            return null;
        };

        // allocate Engine itself from the general-purpose allocator
        // so the pointer is stable
        const e_ptr = alloc.create(Engine) catch {
            interp.deinit();
            gpa.deinit();
            return null;
        };
        e_ptr.* = Engine{
            .interpreter = interp,
            .allocator_storage = gpa,
            .allocator = alloc,
        };
        return e_ptr;
    }

    /// Run one inference. You pass in your input buffer (must match model’s input size),
    /// and it returns the output slice.
    pub fn predict(
        self: *Engine,
        input_ptr: [*]const f32,
        input_len: usize,
        output_ptr: [*]f32,
        output_len: usize,
    ) i8 {
        const in_buf = self.interpreter.getInputBuffer(0);
        if (in_buf.len != input_len) return -1; // input buffer size mismatch

        // copy input
        std.debug.print("\n+++++++++ Getting input buffer\n", .{});
        for (in_buf, 0..) |*dst, i| {
            dst.* = input_ptr[i];
        }

        std.debug.print("\n+++++++++ Running inference ...", .{});
        if (self.interpreter.invoke()) |_| {
            return -2; // error invoking the interpreter
        }
        std.debug.print("\n+++++++++ Inference completed successfully.\n", .{});

        const out_buf = self.interpreter.getOutputBuffer(0);
        if (out_buf.len != output_len) return -3; // output buffer size mismatch
        for (out_buf, 0..) |v, i| {
            output_ptr[i] = v;
        }
        return 0;
    }

    /// Destroy/free the Engine
    pub fn deinit(self: *Engine) void {
        self.interpreter.deinit();
        _ = self.allocator_storage.deinit();
        // free the Engine struct itself:
        self.allocator.destroy(self);
    }
};

//---------------------------------------------------------------------------
// C API exports
//---------------------------------------------------------------------------

/// Opaque handle
pub const EngineHandle = [*]Engine;

/// Errors returned by init
pub const InitError = enum(i32) {
    OutOfMemory = 1,
};

/// export functions with C ABI
export fn inference_init(arena_size: usize) EngineHandle {
    return @ptrCast(Engine.init(arena_size) orelse null);
}

export fn inference_predict(
    h: EngineHandle,
    input_ptr: [*]const f32,
    input_len: usize,
    output_ptr: [*]f32,
    output_len: usize,
) c_int {
    if (h == null) return -10;
    return h.predict(input_ptr, input_len, output_ptr, output_len);
}

export fn inference_deinit(h: EngineHandle) void {
    if (h != null) h.deinit();
}
