const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);
    if (args.len < 2) {
        try stdout.print("Usage: thecompressor <file>\n", .{});
        return;
    }

    var file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var map = std.AutoHashMap(u8, usize).init(std.heap.page_allocator);
    defer map.deinit();

    var buffer: [1024]u8 = undefined;
    while (true) {
        const bytes_read = try file.read(&buffer);
        if (bytes_read == 0) break;

        for (buffer[0..bytes_read]) |c| {
            const entry = map.get(c);
            if (entry) |count| {
                try map.put(c, count + 1);
            } else {
                try map.put(c, 1);
            }
        }
    }

    try stdout.print("Character occurrences:\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        try stdout.print("{c}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}
