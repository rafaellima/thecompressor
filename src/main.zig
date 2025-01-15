const std = @import("std");
const mapChars = @import("file.zig").mapChars;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);
    if (args.len < 2) {
        try stdout.print("Usage: thecompressor <file>\n", .{});
        return;
    }

    var map = try mapChars(args[1]);
    defer map.deinit();

    var iter = map.iterator();
    while (iter.next()) |entry| {
        try stdout.print("{c}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}
