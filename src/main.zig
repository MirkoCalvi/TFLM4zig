const build_options = @import("build_options");

const cc_model = @cImport({
    @cInclude("models/mob_net/model.h");
});

const std = @import("std");
const tflm = @import("tflm.zig");

pub fn main() !void {
    // Print model information
    std.debug.print("\n-----------------------------\n", .{});
    std.debug.print("Model address: {p}\n", .{&cc_model.tfl__model_tflite});
    std.debug.print("Model size: {}\n", .{cc_model.tfl__model_tflite_len});

    // Get model data slice
    const model_data = cc_model.tfl__model_tflite[0..cc_model.tfl__model_tflite_len];
    std.debug.print("Model data size: {x}\n", .{model_data.len});
    std.debug.print("First byte: {x}\n", .{model_data[0]});
    std.debug.print("Last byte: {x}\n", .{model_data[model_data.len - 1]});
    std.debug.print("\n-----------------------------\n", .{});

    // Initialize allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create interpreter with appropriate arena size
    const arena_size = 1024 * 1024 * 600; // 600MB arena
    std.debug.print("\n+++++++++ TFLMInterpreter initialization\n", .{});
    var interpreter = try tflm.TFLMInterpreter.init(allocator, arena_size, model_data);
    defer interpreter.deinit();

    // Get and check input buffer size
    std.debug.print("\n+++++++++ Getting input buffer\n", .{});
    const input_buffer = interpreter.getInputBuffer(0);
    std.debug.print("Input buffer size: {}\n", .{input_buffer.len});

    // Fill input with test data
    for (input_buffer, 0..) |*val, i| {
        val.* = @as(f32, @floatFromInt(i)) * 0.01;
    }

    // Run inference
    std.debug.print("\n+++++++++ Running inference\n", .{});
    try interpreter.invoke();

    // Get and process output
    const output_buffer = interpreter.getOutputBuffer(0);
    std.debug.print("Output buffer size: {}\n", .{output_buffer.len});

    // Print results
    std.debug.print("\n+++++++++ Results:\n", .{});
    for (output_buffer, 0..) |val, i| {
        std.debug.print("Input[{}]: {d:.4} -> Output[{}]: {d:.4}\n", .{ i, input_buffer[i], i, val });
    }

    // Find the class with highest confidence
    var max_idx: usize = 0;
    var max_val: f32 = output_buffer[0];
    for (output_buffer[1..], 1..) |val, i| {
        if (val > max_val) {
            max_val = val;
            max_idx = i;
        }
    }

    std.debug.print("\nPredicted class: {} (confidence: {d:.4})\n", .{ max_idx, max_val });
    std.debug.print("\n-----------------------------\n", .{});
}
