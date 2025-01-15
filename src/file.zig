const std = @import("std");
const expect = std.testing.expect;

pub fn mapChars(filename: []const u8) !std.AutoHashMap(u8, usize) {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var map = std.AutoHashMap(u8, usize).init(std.heap.page_allocator);

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

    return map;
}

test "mapChars" {
    var map = try mapChars("test/sample.txt");
    defer map.deinit();

    try expect(map.getEntry('H').?.value_ptr.* == 1);
    try expect(map.getEntry('e').?.value_ptr.* == 1);
    try expect(map.getEntry('l').?.value_ptr.* == 3);
    try expect(map.getEntry('o').?.value_ptr.* == 2);
    try expect(map.getEntry(' ').?.value_ptr.* == 1);
    try expect(map.getEntry('W').?.value_ptr.* == 1);
    try expect(map.getEntry('r').?.value_ptr.* == 1);
    try expect(map.getEntry('d').?.value_ptr.* == 1);
    try expect(map.getEntry('!').?.value_ptr.* == 1);
}
