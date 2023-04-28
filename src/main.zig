const std = @import("std");
const napigen = @import("./gen_napi.zig");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

pub const allocator = std.heap.c_allocator;

comptime {
    napigen.define_module(initModule);
}

fn testSliceOut() ![]i32 {
    var slice: []i32 = try napigen.allocator.alloc(i32, 10);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i32, i);
    }
    return slice;
}

fn testSliceIn(slice: []i32) void {
    std.debug.print("slice: {any}\n", .{slice});
}

fn initModule(js: *napigen.JSCtx, exports: napigen.napi_value) !napigen.napi_value {
    @setEvalBranchQuota(100_000);
    inline for (comptime std.meta.declarations(fl)) |d| {
        // functions
        if (comptime std.mem.startsWith(u8, d.name, "fl_")) {
            if (comptime std.mem.eql(u8, d.name, "fl_destroyTensor")) continue;

            const T = @TypeOf(@field(fl, d.name));

            if (@typeInfo(T) == .Fn) {
                try js.set_named_property(exports, "" ++ d.name, try js.create_named_function(d.name, @field(fl, d.name)));
            }
            try js.set_named_property(exports, "" ++ "testSliceOut", try js.create_named_function("testSliceOut", testSliceOut));
            try js.set_named_property(exports, "" ++ "testSliceIn", try js.create_named_function("testSliceIn", testSliceIn));
        }
    }

    return exports;
}

const parse_external = [_][]const u8{ "fl_dtype", "fl_dispose", "fl_asContiguousTensor", "fl_elements", "fl_float32Buffer" };

pub fn custom_arg_parser(js: *napigen.JSCtx, comptime T: type, v: napigen.napi_value, comptime name: []const u8) !T {
    inline for (parse_external) |n| {
        if (comptime std.mem.eql(u8, name, n) and T == ?*anyopaque) {
            return js.get_external(T, v);
        }
    }

    return js.arg_parser(T, v, name);
}

fn finalize_tensor(_: napigen.napi_env, finalize_data: ?*anyopaque, finalize_hint: ?*anyopaque) callconv(.C) void {
    return fl.fl_destroyTensor(finalize_data, finalize_hint);
}

const create_external = [_][]const u8{ "fl_tensorFromFloat32Buffer", "fl_asContiguousTensor" };

pub fn custom_return_handler(js: *napigen.JSCtx, v: anytype, comptime name: []const u8, c_array_len: *usize) !napigen.napi_value {
    inline for (create_external) |n| {
        if (comptime std.mem.eql(u8, name, n)) {
            return js.create_external(@ptrCast(*anyopaque, @constCast(v)), finalize_tensor, null);
        }
    }

    return js.return_handler(v, name, c_array_len);
}
