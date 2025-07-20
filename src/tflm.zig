const std = @import("std");

// External C functions
extern fn tflm_init() void;
extern fn tflm_create_interpreter_from_model(tensor_arena: [*]u8, arena_size: usize) ?*opaque {};
extern fn tflm_get_input_buffer(interp: *opaque {}, input_index: c_int) [*]f32;
extern fn tflm_get_output_buffer(interp: *opaque {}, output_index: c_int) [*]f32;
extern fn tflm_invoke(interp: *opaque {}) c_int;
extern fn tflm_get_input_size(interp: *opaque {}, input_index: c_int) c_int;
extern fn tflm_get_output_size(interp: *opaque {}, output_index: c_int) c_int;

pub const TFLMInterpreter = struct {
    handle: *opaque {},
    arena: []u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, arena_size: usize) !TFLMInterpreter {
        tflm_init();

        const arena = try allocator.alloc(u8, arena_size);

        const handle = tflm_create_interpreter_from_model(arena.ptr, arena_size) orelse return error.InterpreterCreationFailed;

        return TFLMInterpreter{
            .handle = handle,
            .arena = arena,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *TFLMInterpreter) void {
        self.allocator.free(self.arena);
    }

    pub fn getInputBuffer(self: *TFLMInterpreter, input_index: i32) []f32 {
        const ptr = tflm_get_input_buffer(self.handle, input_index);
        const size = tflm_get_input_size(self.handle, input_index);
        return ptr[0..@intCast(size)];
    }

    pub fn getOutputBuffer(self: *TFLMInterpreter, output_index: i32) []f32 {
        const ptr = tflm_get_output_buffer(self.handle, output_index);
        const size = tflm_get_output_size(self.handle, output_index);
        return ptr[0..@intCast(size)];
    }

    pub fn invoke(self: *TFLMInterpreter) !void {
        const result = tflm_invoke(self.handle);
        if (result != 0) {
            return error.InferenceFailed;
        }
    }
};
