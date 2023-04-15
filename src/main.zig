const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("bindings.h");
});

pub fn main() !void {
    c.bytesUsed();
}

test "basic testFn functionality" {
    try testing.expect(main());
}
