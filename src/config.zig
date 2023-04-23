const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const config = try readConfig("config.json");
    std.debug.print("config.root: {s}\n", .{config.root});
}

fn readConfig(allocator: Allocator, path: []const u8) !Config {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);
    //TODO: all our logic here!

    // since we're not using path yet, we need this to satisfy the compiler
    return error.NotImplemented;
}

const Config = struct {
    root: []const u8,
};
