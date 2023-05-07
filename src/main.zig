const std = @import("std");
const napigen = @import("./gen_napi.zig");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

comptime {
    napigen.define_module(initModule);
}

fn slice_to_Int8Array(allocator: std.mem.Allocator) ![]i8 {
    var slice: []i8 = try allocator.alloc(i8, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i8, i);
    }
    return slice;
}

fn slice_to_Int16Array(allocator: std.mem.Allocator) ![]i16 {
    var slice: []i16 = try allocator.alloc(i16, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i16, i);
    }
    return slice;
}

fn slice_to_Int32Array(allocator: std.mem.Allocator) ![]i32 {
    var slice: []i32 = try allocator.alloc(i32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i32, i);
    }
    return slice;
}

fn slice_to_BigInt64Array(allocator: std.mem.Allocator) ![]i64 {
    var slice: []i64 = try allocator.alloc(i64, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(i64, i);
    }
    return slice;
}

fn slice_to_Uint8Array(allocator: std.mem.Allocator) ![]u8 {
    var slice: []u8 = try allocator.alloc(u8, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u8, i);
    }
    return slice;
}

fn slice_to_Uint16Array(allocator: std.mem.Allocator) ![]u16 {
    var slice: []u16 = try allocator.alloc(u16, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u16, i);
    }
    return slice;
}

fn slice_to_Uint32Array(allocator: std.mem.Allocator) ![]u32 {
    var slice: []u32 = try allocator.alloc(u32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u32, i);
    }
    return slice;
}

fn slice_to_BigUint64Array(allocator: std.mem.Allocator) ![]u64 {
    var slice: []u64 = try allocator.alloc(u64, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intCast(u64, i);
    }
    return slice;
}

fn slice_to_Float32Array(allocator: std.mem.Allocator) ![]f32 {
    var slice: []f32 = try allocator.alloc(f32, 100);
    for (slice, 0..) |_, i| {
        slice[i] = @intToFloat(f32, i);
    }
    return slice;
}

fn slice_to_Float64Array(allocator: std.mem.Allocator) ![]f64 {
    var slice: []f64 = try allocator.alloc(f64, 100);
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

fn round_trip_string(s: []const u8) []const u8 {
    return s;
}

fn concat_strings(allocator: std.mem.Allocator, a: []const u8, b: []const u8, c: []const u8) ![]const u8 {
    return try std.mem.join(allocator, "", &.{ a, b, c });
}

fn new_string() []const u8 {
    return "Hello, World!";
}

fn bool_true() bool {
    return true;
}

fn bool_false() bool {
    return false;
}

fn negate_bool(v: bool) bool {
    return !v;
}

const DemoStruct = struct {
    a: i32,
    b: i32,
    c: []const u8,
};

fn returns_struct() DemoStruct {
    return DemoStruct{ .a = 1, .b = 2, .c = "Hello, World!" };
}

fn round_trip_struct(v: DemoStruct) DemoStruct {
    return DemoStruct{ .a = v.a + 1, .b = v.b + 1, .c = v.c };
}

const DemoStruct2 = struct {
    a: i32,
    b: i64,
};

fn wrapped_struct(alloc: std.mem.Allocator, a: i32, b: i64) !*DemoStruct2 {
    var res: *DemoStruct2 = try alloc.create(DemoStruct2);
    res.* = DemoStruct2{ .a = a, .b = b };
    return res;
}

fn wrapped_struct_get_a(v: *DemoStruct2) i32 {
    return v.a;
}

fn wrapped_struct_get_b(v: *DemoStruct2) i64 {
    return v.b;
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
    try js.set_named_property(exports, "round_trip_string", try js.create_named_function("round_trip_string", round_trip_string));
    try js.set_named_property(exports, "concat_strings", try js.create_named_function("concat_strings", concat_strings));
    try js.set_named_property(exports, "new_string", try js.create_named_function("new_string", new_string));
    try js.set_named_property(exports, "bool_true", try js.create_named_function("bool_true", bool_true));
    try js.set_named_property(exports, "bool_false", try js.create_named_function("bool_false", bool_false));
    try js.set_named_property(exports, "negate_bool", try js.create_named_function("negate_bool", negate_bool));
    try js.set_named_property(exports, "returns_struct", try js.create_named_function("returns_struct", returns_struct));
    try js.set_named_property(exports, "round_trip_struct", try js.create_named_function("round_trip_struct", round_trip_struct));
    try js.set_named_property(exports, "wrapped_struct", try js.create_named_function("wrapped_struct", wrapped_struct));
    try js.set_named_property(exports, "wrapped_struct_get_a", try js.create_named_function("wrapped_struct_get_a", wrapped_struct_get_a));
    try js.set_named_property(exports, "wrapped_struct_get_b", try js.create_named_function("wrapped_struct_get_b", wrapped_struct_get_b));

    return exports;
}

const parse_external = [_][]const u8{ "fl_dtype", "fl_dispose", "fl_asContiguousTensor", "fl_elements", "fl_float32Buffer" };

pub fn custom_arg_parser(js: *napigen.JSCtx, comptime T: type, v: napigen.napi_value, comptime ctx: napigen.FnCtx) !T {
    inline for (parse_external) |n| {
        if (comptime std.mem.eql(u8, ctx.name, n) and T == ?*anyopaque) {
            return js.get_external(T, v);
        }
    }

    return js.arg_parser(T, v, ctx);
}

fn finalize_tensor(_: napigen.napi_env, finalize_data: ?*anyopaque, finalize_hint: ?*anyopaque) callconv(.C) void {
    return fl.fl_destroyTensor(finalize_data, finalize_hint);
}

const create_external = [_][]const u8{ "fl_tensorFromFloat32Buffer", "fl_asContiguousTensor" };

pub fn custom_return_handler(js: *napigen.JSCtx, v: anytype, comptime ctx: napigen.FnCtx) !napigen.napi_value {
    inline for (create_external) |n| {
        if (comptime std.mem.eql(u8, ctx.name, n)) {
            return js.create_external_with_finalizer(@ptrCast(*anyopaque, @constCast(v)), finalize_tensor, null);
        }
    }

    return js.return_handler(v, ctx);
}
