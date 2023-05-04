const std = @import("std");

pub fn readConfig(allocator: std.mem.Allocator, path: []const u8) !Config {
    const data: []u8 = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);

    var stream = std.json.TokenStream.init(data);
    return try std.json.parse(Config, &stream, .{ .allocator = allocator });
}

pub const FnArgs = struct {
    name: []const u8,
    mapped_type: ?[]const u8 = null,
    skip: bool = false,
};

const WrappedMethod = struct {
    name: []const u8,
    args: []FnArgs,
};

const Config = struct {
    ts_out_path: []const u8,
    wrapped_methods: []WrappedMethod,
    bindings_path: []const u8,

    const Self = @This();

    pub fn deinit(self: Self, allocator: std.mem.Allocator) void {
        return std.json.parseFree(Config, self, .{ .allocator = allocator });
    }
};
