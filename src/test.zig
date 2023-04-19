const std = @import("std");
const napigen = @import("napigen");
const napi = @import("c");

const testing = std.testing;

const c = @cImport({
    @cInclude("../cpp/flashlight_binding.h");
});

comptime {
    napigen.defineModule(initModule);
}

export fn bytesUsed() i64 {
    const bytes = c.bytesUsed();
    return @bitCast(i64, bytes);
}

export fn init() void {
    c.init();
}

fn initModule(js: *napigen.JsContext, exports: napigen.napi_value) !napigen.napi_value {
    // comptime {
    // @setEvalBranchQuota(10_000);
    // inline for (std.meta.declarations(c)) |decl| {
    // if (!decl.is_pub) continue;
    // if (std.mem.startsWith(u8, decl.name, "__")) continue;
    // if (std.mem.eql(u8, decl.name, "offsetof")) continue;
    // const d = @field(c, decl.name);
    // const ti = @typeInfo(@TypeOf(d));
    // if (ti != .Fn) continue;
    // try js.setNamedProperty(exports, decl.name, try js.createFunction(d));
    // }
    //  }
    try js.setNamedProperty(exports, "init", try js.createFunction(init));

    try js.setNamedProperty(exports, "bytesUsed", try js.createFunction(bytesUsed));

    return exports;
}

test "bytesUsed" {
    try testing.expect(c.bytesUsed() == 0);
}
