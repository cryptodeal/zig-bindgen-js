const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("../cpp/flashlight_binding.h");
});

comptime {
    @setEvalBranchQuota(10_000);

    inline for (std.meta.declarations(c)) |decl| {
        if (!decl.is_pub) continue;
        if (std.mem.startsWith(u8, decl.name, "__")) continue;
        if (std.mem.eql(u8, decl.name, "offsetof")) continue;
        const d = @field(c, decl.name);
        const ti = @typeInfo(@TypeOf(d));
        if (ti != .Fn) continue;

        const fi = ti.Fn;

        @compileLog(decl.name, fi);
    }
}
