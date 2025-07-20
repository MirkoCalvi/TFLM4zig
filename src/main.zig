const cc_model = @cImport({
    @cInclude("model/model.h");
});

const std = @import("std");
const tflm = @import("tflm.zig");

pub fn main() !void {
    std.debug.print("\n-----------------------------\n", .{});
    std.debug.print("Model address: {p}\n", .{&cc_model.models_audio_tflite});
    std.debug.print("Model size: {}\n", .{cc_model.models_audio_tflite_len});
    // Example: Slice over the model data
    const data = cc_model.models_audio_tflite[0..cc_model.models_audio_tflite_len];
    std.debug.print("model_data size: {x}\n", .{data.len});
    std.debug.print("First byte: {x}\n", .{data[0]});
    std.debug.print("last -5 byte: {x}\n", .{data[data.len - 5]});
    std.debug.print("\n-----------------------------\n", .{});

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();

    // // Create interpreter with appropriate arena size
    // // For micro_speech model, typically 20KB is sufficient
    // const arena_size = 2048 * 10; // 20KB arena
    // var interpreter = try tflm.TFLMInterpreter.init(allocator, arena_size);
    // defer interpreter.deinit();

    // // Get input buffer and populate it with your data
    // const input_buffer = interpreter.getInputBuffer(0);
    // std.log.info("Input buffer size: {}", .{input_buffer.len});

    // // For micro_speech, input is typically 1960 features (audio spectrogram)
    // // Example: Fill input with some test data
    // for (input_buffer, 0..) |*val, i| {
    //     val.* = @as(f32, @floatFromInt(i)) * 0.001; // Small values for audio features
    // }

    // // Run inference
    // try interpreter.invoke();

    // // Get output (for micro_speech, typically 4 classes: silence, unknown, yes, no)
    // const output_buffer = interpreter.getOutputBuffer(0);
    // std.log.info("Output buffer size: {}", .{output_buffer.len});

    // // Print results
    // const classes = [_][]const u8{ "Silence", "Unknown", "Yes", "No" };
    // for (output_buffer, 0..) |val, i| {
    //     if (i < classes.len) {
    //         std.log.info("{s}: {d:.4}", .{ classes[i], val });
    //     } else {
    //         std.log.info("Output[{}]: {d:.4}", .{ i, val });
    //     }
    // }

    // // Find the class with highest confidence
    // var max_idx: usize = 0;
    // var max_val: f32 = output_buffer[0];
    // for (output_buffer[1..], 1..) |val, i| {
    //     if (val > max_val) {
    //         max_val = val;
    //         max_idx = i;
    //     }
    // }

    // if (max_idx < classes.len) {
    //     std.log.info("Predicted: {s} (confidence: {d:.4})", .{ classes[max_idx], max_val });
    // }
}
