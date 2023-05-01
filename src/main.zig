const std = @import("std");
const napigen = @import("./gen_napi.zig");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

comptime {
    napigen.define_module(initModule);
}

fn slice_to_Int8Array() ![]i8 {
    var slice: []i8 = try napigen.allocator.alloc(i8, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i8, i);
    }
    return slice;
}

fn slice_to_Int16Array() ![]i16 {
    var slice: []i16 = try napigen.allocator.alloc(i16, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i16, i);
    }
    return slice;
}

fn slice_to_Int32Array() ![]i32 {
    var slice: []i32 = try napigen.allocator.alloc(i32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i32, i);
    }
    return slice;
}

fn slice_to_BigInt64Array() ![]i64 {
    var slice: []i64 = try napigen.allocator.alloc(i64, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i64, i);
    }
    return slice;
}

fn slice_to_Uint8Array() ![]u8 {
    var slice: []u8 = try napigen.allocator.alloc(u8, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u8, i);
    }
    return slice;
}

fn slice_to_Uint16Array() ![]u16 {
    var slice: []u16 = try napigen.allocator.alloc(u16, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u16, i);
    }
    return slice;
}

fn slice_to_Uint32Array() ![]u32 {
    var slice: []u32 = try napigen.allocator.alloc(u32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u32, i);
    }
    return slice;
}

fn slice_to_BigUint64Array() ![]u64 {
    var slice: []u64 = try napigen.allocator.alloc(u64, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u64, i);
    }
    return slice;
}

fn slice_to_Float32Array() ![]f32 {
    var slice: []f32 = try napigen.allocator.alloc(f32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intToFloat(f32, i);
    }
    return slice;
}

fn slice_to_Float64Array() ![]f64 {
    var slice: []f64 = try napigen.allocator.alloc(f64, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intToFloat(f64, i);
    }
    return slice;
}

fn add_i8(a: i8, b: i8) i8 {
    return a + b;
}

fn add_i16(a: i16, b: i16) i16 {
    return a + b;
}

fn add_i32(a: i32, b: i32) i32 {
    return a + b;
}

fn add_i64(a: i64, b: i64) i64 {
    return a + b;
}

fn add_u8(a: u8, b: u8) u8 {
    return a + b;
}

fn add_u16(a: u16, b: u16) u16 {
    return a + b;
}

fn add_u32(a: u32, b: u32) u32 {
    return a + b;
}

fn add_u64(a: u64, b: u64) u64 {
    return a + b;
}

fn add_f32(a: f32, b: f32) f32 {
    return a + b;
}

fn add_f64(a: f64, b: f64) f64 {
    return a + b;
}

fn initModule(js: *napigen.JSCtx, exports: napigen.napi_value) !napigen.napi_value {
    @setEvalBranchQuota(100_000);
    inline for (comptime std.meta.declarations(fl)) |d| {
        // shumai bindings demo (WIP)
        if (comptime std.mem.startsWith(u8, d.name, "fl_")) {
            if (comptime std.mem.eql(u8, d.name, "fl_destroyTensor")) continue;

            const T = @TypeOf(@field(fl, d.name));

            if (@typeInfo(T) == .Fn) {
                try js.set_named_property(exports, "" ++ d.name, try js.create_named_function(d.name, @field(fl, d.name)));
            }
        }
    }

    // unit test functions
    try js.set_named_property(exports, "slice_to_Int8Array", try js.create_named_function("slice_to_Int8Array", slice_to_Int8Array));
    try js.set_named_property(exports, "slice_to_Int16Array", try js.create_named_function("slice_to_Int16Array", slice_to_Int16Array));
    try js.set_named_property(exports, "slice_to_Int32Array", try js.create_named_function("slice_to_Int32Array", slice_to_Int32Array));
    try js.set_named_property(exports, "slice_to_BigInt64Array", try js.create_named_function("slice_to_BigInt64Array", slice_to_BigInt64Array));
    try js.set_named_property(exports, "slice_to_Uint8Array", try js.create_named_function("slice_to_Uint8Array", slice_to_Uint8Array));
    try js.set_named_property(exports, "slice_to_Uint16Array", try js.create_named_function("slice_to_Uint16Array", slice_to_Uint16Array));
    try js.set_named_property(exports, "slice_to_Uint32Array", try js.create_named_function("slice_to_Uint32Array", slice_to_Uint32Array));
    try js.set_named_property(exports, "slice_to_BigUint64Array", try js.create_named_function("slice_to_BigUint64Array", slice_to_BigUint64Array));
    try js.set_named_property(exports, "slice_to_Float32Array", try js.create_named_function("slice_to_Float32Array", slice_to_Float32Array));
    try js.set_named_property(exports, "slice_to_Float64Array", try js.create_named_function("slice_to_Float64Array", slice_to_Float64Array));
    try js.set_named_property(exports, "add_i8", try js.create_named_function("add_i8", add_i8));
    try js.set_named_property(exports, "add_i16", try js.create_named_function("add_i16", add_i16));
    try js.set_named_property(exports, "add_i32", try js.create_named_function("add_i32", add_i32));
    try js.set_named_property(exports, "add_i64", try js.create_named_function("add_i64", add_i64));
    try js.set_named_property(exports, "add_u8", try js.create_named_function("add_u8", add_u8));
    try js.set_named_property(exports, "add_u16", try js.create_named_function("add_u16", add_u16));
    try js.set_named_property(exports, "add_u32", try js.create_named_function("add_u32", add_u32));
    try js.set_named_property(exports, "add_u64", try js.create_named_function("add_u64", add_u64));
    try js.set_named_property(exports, "add_f32", try js.create_named_function("add_f32", add_f32));
    try js.set_named_property(exports, "add_f64", try js.create_named_function("add_f64", add_f64));

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
