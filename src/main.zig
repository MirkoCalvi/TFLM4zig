const std = @import("std");
const infer = @import("inference_engine.zig");

pub fn main() !void {
    const arena_size = @floor(0.8 * 1024 * 1024); // 0.4 MB
    _ = infer.inference_init(arena_size) orelse {
        std.debug.print("OOM initializing\n", .{});
        return;
    };
    defer infer.inference_deinit();

    const in_buf = infer.inference_input_buffer_ptr();
    const in_len = infer.inference_input_len();

    // fill inputs
    // var prng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    // const rng = prng.random();
    for (in_buf[0..in_len]) |*val| {
        val.* = 1;
        // rng.float(f32) * @as(f32, @floatFromInt(rng.intRangeAtMost(i8, -120, 120)));
    }
    // run
    _ = infer.inference_invoke();

    var out_buf = infer.inference_output_buffer_ptr();
    const out_len = infer.inference_output_len();

    // find best
    var best: usize = 0;
    for (out_buf[0..out_len], 0..) |val, i| {
        if (val > out_buf[best]) best = i + 1;
        std.debug.print("Output[{}] = {}\n", .{ i + 1, val });
    }
    std.debug.print("Predicted {} @ {}\n", .{ best, out_buf[best] });
}
