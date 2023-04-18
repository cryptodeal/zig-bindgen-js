const std = @import("std");

const FnData = struct {
    name: []const u8,
    data: std.builtin.Type.Fn,
};
