const std = @import("std");

// Opaque type for the interpreter handle
const InterpreterHandle = opaque {};

extern fn tflm_init() void;

extern fn tflm_create_interpreter_from_model(
    arena_buf: [*]u8,
    arena_size: usize,
    model_data: [*]const u8,
) ?*InterpreterHandle;

extern fn tflm_get_input_buffer(
    handle: *InterpreterHandle,
    input_index: i32,
) [*]f32;

extern fn tflm_get_output_buffer(
    handle: *InterpreterHandle,
    output_index: i32,
) [*]f32;

extern fn tflm_invoke(
    handle: *InterpreterHandle,
) i32;

extern fn tflm_get_input_size(
    handle: *InterpreterHandle,
    input_index: i32,
) i32;

extern fn tflm_get_output_size(
    handle: *InterpreterHandle,
    output_index: i32,
) i32;

pub const TFLMInterpreter = struct {
    handle: *InterpreterHandle,
    arena: []u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, arena_size: usize, model_data: []const u8) !TFLMInterpreter {
        std.debug.print("Initializing TFLM interpreter...\n", .{});
        tflm_init();

        std.debug.print("Allocating arena of size {}...\n", .{arena_size});
        const arena = try allocator.alloc(u8, arena_size);
        errdefer allocator.free(arena);

        std.debug.print("Creating interpreter with model data of size {}...\n", .{model_data.len});
        const handle = tflm_create_interpreter_from_model(
            arena.ptr,
            arena_size,
            model_data.ptr,
        ) orelse {
            std.debug.print("Failed to create interpreter!\n", .{});
            return error.InterpreterCreationFailed;
        };

        std.debug.print("Interpreter created successfully\n", .{});
        return TFLMInterpreter{
            .handle = handle,
            .arena = arena,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *TFLMInterpreter) void {
        self.allocator.free(self.arena);
    }

    pub fn getInputBuffer(self: *const TFLMInterpreter, input_index: i32) []f32 {
        const size = tflm_get_input_size(self.handle, input_index);
        const ptr = tflm_get_input_buffer(self.handle, input_index);
        return ptr[0..@intCast(size)];
    }

    pub fn getOutputBuffer(self: *const TFLMInterpreter, output_index: i32) []f32 {
        const size = tflm_get_output_size(self.handle, output_index);
        const ptr = tflm_get_output_buffer(self.handle, output_index);
        return ptr[0..@intCast(size)];
    }

    pub fn invoke(self: *const TFLMInterpreter) !void {
        if (tflm_invoke(self.handle) != 0) {
            return error.InvokeFailed;
        }
    }
};
