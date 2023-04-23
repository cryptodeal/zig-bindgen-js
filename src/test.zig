const std = @import("std");
const napi = @import("c");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

const testing = std.testing;

const c = @cImport({
    @cInclude("../cpp/flashlight_binding.h");
});

export fn bytesUsed() i64 {
    const bytes = c.bytesUsed();
    return @bitCast(i64, bytes);
}

export fn init() void {
    c.init();
}

const CFunctionData = struct {
    name: []const u8,
    data: std.builtin.Type.Fn,
};

var list = std.ArrayList(CFunctionData).init(std.heap.ArenaAllocator);

comptime {
    @setEvalBranchQuota(10_000);
    inline for (std.meta.declarations(fl)) |decl| {
        if (!decl.is_pub) continue;
        if (std.mem.startsWith(u8, decl.name, "__")) continue;
        if (std.mem.eql(u8, decl.name, "offsetof")) continue;
        const d = @field(fl, decl.name);
        const ti = @typeInfo(@TypeOf(d));
        if (ti != .Fn) continue;
        if (ti.Fn.calling_convention != .C) continue;
        @compileLog(decl.name, ti.Fn);
    }
}
