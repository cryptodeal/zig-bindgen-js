const std = @import("std");
const gen_node = @import("src/gen_ts.zig");

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

const args = [_]gen_node.FnArgs{ .{ .name = "a" }, .{ .name = "b" } };
const info: gen_node.FnInfo = .{ .args = @constCast(&args) };

pub fn main() !void {
    var builder = try gen_node.TSExports.init();
    defer builder.deinit();

    try builder.write_frontmatter("../zig-out/lib/example.node", "");

    try builder.wrap_method("add", add, info);

    try builder.write_wrapper("wrapper/index.ts");
}
