const std = @import("std");
const napigen = @import("./gen_napi.zig");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

comptime {
    napigen.define_module(initModule);
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
        }
    }

    return exports;
}

fn finalize_tensor(env: napigen.napi_env, finalize_data: ?*anyopaque, finalize_hint: ?*anyopaque) callconv(.C) void {
    _ = env;
    return fl.fl_destroyTensor(finalize_data, finalize_hint);
}

pub fn custom_arg_parser(js: *napigen.JSCtx, comptime T: type, v: napigen.napi_value, comptime name: []const u8) !T {
    if ((comptime std.mem.eql(u8, name, "fl_dtype") or std.mem.eql(u8, name, "fl_dispose") or std.mem.eql(u8, name, "fl_asContiguousTensor") or std.mem.eql(u8, name, "fl_elements") or std.mem.eql(u8, name, "fl_float32Buffer")) and T == ?*anyopaque) {
        // std.debug.print("{any}\n", .{T});
        return js.get_external(T, v);
    }

    return js.arg_parser(T, v, name);
}

pub fn custom_return_handler(js: *napigen.JSCtx, v: anytype, comptime name: []const u8, c_array_len: [*c]usize) !napigen.napi_value {

    // std.debug.print("fn name: {s}\n", .{name});
    if (comptime std.mem.eql(u8, name, "fl_tensorFromFloat32Buffer") or std.mem.eql(u8, name, "fl_asContiguousTensor")) {
        return js.create_external(@ptrCast(*anyopaque, @constCast(v)), finalize_tensor, null);
    }
    return js.return_handler(v, name, c_array_len);
}
