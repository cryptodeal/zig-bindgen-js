const std = @import("std");
const root = @import("root");
const napi = @import("napi.zig");

pub usingnamespace napi;

const trait = std.meta.trait;

// define error types
pub const NapiErrorTypes = error{ napi_invalid_arg, napi_object_expected, napi_string_expected, napi_name_expected, napi_function_expected, napi_number_expected, napi_boolean_expected, napi_array_expected, napi_generic_failure, napi_pending_exception, napi_cancelled, napi_escape_called_twice, napi_handle_scope_mismatch, napi_callback_scope_mismatch, napi_queue_full, napi_closing, napi_bigint_expected, napi_date_expected, napi_arraybuffer_expected, napi_detachable_arraybuffer_expected, napi_would_deadlock };
pub const Error = std.mem.Allocator.Error || error{InvalidArgumentCount} || NapiErrorTypes;
pub const ConversionError = error{ExceptionThrown};

pub const allocator = std.heap.c_allocator;

pub fn err_check(status: napi.napi_status) Error!void {
    if (status != napi.napi_ok) {
        inline for (comptime std.meta.fieldNames(NapiErrorTypes)) |err| {
            if (status == @field(napi, err)) return @field(NapiErrorTypes, err);
        } else @panic("unknown napi error type");
    }
}

pub fn define_module(comptime init: fn (*JSCtx, napi.napi_value) Error!napi.napi_value) void {
    const NapiModule = struct {
        fn register(env: napi.napi_env, exports: napi.napi_value) callconv(.C) napi.napi_value {
            var ctx = JSCtx.init(env) catch @panic("failed to init JS context");
            return init(ctx, exports) catch |err| ctx.create_error(err);
        }
    };
    @export(NapiModule.register, .{ .name = "napi_register_module_v1", .linkage = .Strong });
}

// TODO: use `ArenaAllocator` for tmp allocations
var TEMP_GPA = std.heap.GeneralPurposeAllocator(.{}){};
pub const TEMP = TEMP_GPA.allocator();

pub const JSCtx = struct {
    env: napi.napi_env,
    refs: std.AutoHashMapUnmanaged(usize, napi.napi_ref) = .{},

    // TODO: pass fn name to `parse` and `write` hooks

    // parse hook (handles conversion: JS -> Native)
    pub const parse = if (@hasDecl(root, "custom_arg_parser")) root.custom_arg_parser else arg_parser;
    pub fn arg_parser(self: *JSCtx, comptime T: type, v: napi.napi_value, _: []const u8) Error!T {
        if (T == napi.napi_value) return v;
        if (comptime trait.isZigString(T)) return self.get_string(v);
        std.debug.print("{any}\n", .{@typeInfo(T)});
        std.debug.print("{any}\n", .{T});

        // TODO: refactor this mess lmao
        if (comptime std.mem.startsWith(u8, @typeName(T), "[*c]")) {
            const type_info = comptime @typeInfo(T);
            const data_type = comptime type_info.Pointer.child;
            if (comptime data_type == f32 or data_type == f64 or data_type == u8 or data_type == u16 or data_type == u32 or data_type == u64 or data_type == i8 or data_type == i16 or data_type == i32 or data_type == i64) {
                return self.get_typed_array_data(T, v);
            }
        }

        return switch (@typeInfo(T)) {
            .Void => void{},
            .Null => null,
            .Bool => self.get_boolean(v),
            .Int, .ComptimeInt, .Float, .ComptimeFloat => self.get_number(T, v),
            .Enum => std.meta.intToEnum(T, self.get_number(u32, v)),
            .Struct => if (trait.isTuple(T)) self.get_tuple(T, v) else self.get_object(T, v),
            .Optional => |info| self.get_optional(info.child, v),
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => |info| self.unwrap_object(info.child, v),
            else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    // write hook (handles conversion: Native -> JS)
    pub const write = if (@hasDecl(root, "custom_return_handler")) root.custom_return_handler else return_handler;
    pub fn return_handler(self: *JSCtx, v: anytype, _: []const u8) Error!napi.napi_value {
        const T = @TypeOf(v);
        if (T == napi.napi_value) return v;
        if (comptime trait.isZigString(T)) return self.create_string(v);
        return switch (@typeInfo(T)) {
            .Void => self.undefined(),
            .Null => self.null(),
            .Bool => self.create_boolean(v),
            .Int, .ComptimeInt, .Float, .ComptimeFloat => self.create_number(v),
            .Enum => self.create_number(@as(u32, @enumToInt(v))),
            .Struct => if (trait.isTuple(T)) self.create_tuple(v) else self.create_object_from(v),
            .Optional => self.create_optional(v),
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => self.wrap_object(v),
            else => @compileError("returning " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    pub fn init(env: napi.napi_env) Error!*JSCtx {
        var self = try allocator.create(JSCtx);
        try err_check(napi.napi_set_instance_data(env, self, finalize, null));
        self.* = .{ .env = env };
        return self;
    }

    pub fn deinit(self: *JSCtx) void {
        allocator.destroy(self);
    }

    fn get_instance(env: napi.napi_env) *JSCtx {
        var res: *JSCtx = undefined;
        err_check(napi.napi_get_instance_data(env, @ptrCast([*c]?*anyopaque, &res))) catch @panic("could not get JS context");
        return res;
    }

    fn finalize(env: napi.napi_env, _: ?*anyopaque, _: ?*anyopaque) callconv(.C) void {
        get_instance(env).deinit();
    }

    fn type_of(self: *JSCtx, v: napi.napi_value) Error!napi.napi_valuetype {
        var res: napi.napi_valuetype = undefined;
        try err_check(napi.napi_typeof(self.env, v, &res));
        return res;
    }

    pub fn create_error(self: *JSCtx, err: anyerror) napi.napi_value {
        const msg = @ptrCast([*c]const u8, @errorName(err));
        err_check(napi.napi_throw_error(self.env, null, msg)) catch |e| {
            if (e != error.napi_pending_exception) std.debug.panic("throw failed {s} {any}", .{ msg, e });
        };
        return self.undefined() catch @panic("throw return undefined");
    }

    pub fn throw(self: *JSCtx, env: self.napi_env, comptime message: [:0]const u8) ConversionError {
        var result = napi.napi_throw_error(env, null, message);
        switch (result) {
            napi.napi_ok, napi.napi_pending_exception => {},
            else => unreachable,
        }
        return ConversionError.ExceptionThrown;
    }

    pub fn @"undefined"(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_undefined(self.env, &res));
        return res;
    }

    pub fn @"null"(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_null(self.env, &res));
        return res;
    }

    pub fn create_boolean(self: *JSCtx, v: bool) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_boolean(self.env, v, &res));
        return res;
    }

    pub fn get_boolean(self: *JSCtx, v: napi.napi_value) Error!bool {
        var res: bool = undefined;
        try err_check(napi.napi_get_value_bool(self.env, v, &res));
        return res;
    }

    pub fn create_number(self: *JSCtx, val: anytype) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        switch (@TypeOf(val)) {
            u8, u16, u32, c_uint => try err_check(napi.napi_create_uint32(self.env, val, &res)),
            u64, usize => try err_check(napi.napi_create_bigint_uint64(self.env, val, &res)),
            i8, i16, i32, c_int => try err_check(napi.napi_create_int32(self.env, val, &res)),
            i64, isize, @TypeOf(0) => try err_check(napi.napi_create_bigint_int64(self.env, val, &res)),
            f16, f32, f64, @TypeOf(0.0) => try err_check(napi.napi_create_double(self.env, val, &res)),
            else => |T| @compileError(@typeName(T) ++ " is not supported number"),
        }
        return res;
    }

    pub fn get_number(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: T = undefined;
        var loss: bool = undefined; // TODO: check overflow?
        switch (T) {
            u8, u16 => res = @truncate(T, try self.get_number(u32, v)),
            u32, c_uint => try err_check(napi.napi_get_value_uint32(self.env, v, &res)),
            u64, usize => try err_check(napi.napi_get_value_bigint_uint64(self.env, v, &res, &loss)),
            i8, i16 => res = @truncate(T, self.get_number(i32, v)),
            i32, c_int => try err_check(napi.napi_get_value_int32(self.env, v, &res)),
            i64, isize => try err_check(napi.napi_get_value_bigint_int64(self.env, v, &res, &loss)),
            f16, f32 => res = @floatCast(T, try self.get_number(f64, v)),
            f64 => try err_check(napi.napi_get_value_double(self.env, v, &res)),
            else => @compileError(@typeName(T) ++ " is not supported number"),
        }
        return res;
    }

    pub fn create_string(self: *JSCtx, v: []const u8) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_string_utf8(self.env, @ptrCast([*c]const u8, v), v.len, &res));
        return res;
    }

    pub fn get_string_length(self: *JSCtx, v: napi.napi_value) Error!usize {
        var res: usize = undefined;
        try err_check(napi.napi_get_value_string_utf8(self.env, v, null, 0, &res));
        return res;
    }

    pub fn get_string(self: *JSCtx, v: napi.napi_value) Error![]const u8 {
        var len: usize = undefined;
        try err_check(napi.napi_get_value_string_utf8(self.env, v, null, 0, &len));
        var buf = try TEMP.alloc(u8, len + 1);
        try err_check(napi.napi_get_value_string_utf8(self.env, v, @ptrCast([*c]u8, buf), buf.len, &len));
        return buf[0..len];
    }

    pub fn create_optional(self: *JSCtx, v: anytype) Error!napi.napi_value {
        return if (v) |value| self.write(value, "") else self.null();
    }

    pub fn get_optional(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!?T {
        return if (try self.type_of(v) == napi.napi_null) null else self.parse(T, v, "");
    }

    pub fn create_array(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_array(self.env, &res));
        return res;
    }

    pub fn create_array_with_length(self: *JSCtx, len: u32) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_array_with_length(self.env, len, &res));
        return res;
    }

    pub fn get_array_length(self: *JSCtx, v: napi.napi_value) Error!u32 {
        var res: u32 = undefined;
        try err_check(napi.napi_get_array_length(self.env, v, &res));
        return res;
    }

    pub fn get_element(self: *JSCtx, v: napi.napi_value, i: u32) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_element(self.env, v, i, &res));
        return res;
    }

    pub fn set_element(self: *JSCtx, array: napi.napi_value, i: u32, v: napi.napi_value) Error!void {
        try err_check(napi.napi_set_element(self.env, array, i, v));
    }

    pub fn create_tuple(self: *JSCtx, v: anytype) Error!napi.napi_value {
        const fields = std.meta.fields(@TypeOf(v));
        var res = try self.create_array_with_length(fields.len);
        inline for (fields, 0..) |field, i| {
            var tmp_val = try self.write(@field(v, field.name));
            try self.set_element(res, @truncate(u32, i), tmp_val);
        }
        return res;
    }

    pub fn get_tuple(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        const fields = std.meta.fields(T);
        var res: T = undefined;
        inline for (fields, 0..) |field, i| {
            var tmp_val = try self.get_element(v, @truncate(u32, i));
            @field(res, field.name) = try self.parse(field.type, tmp_val);
        }
        return res;
    }

    pub fn create_object(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_object(self.env, &res));
        return res;
    }

    pub fn create_object_from(self: *JSCtx, v: anytype) Error!napi.napi_value {
        var res: napi.napi_value = try self.create_object();
        inline for (std.meta.fields(@TypeOf(v))) |field| {
            var tmp_val = try self.write(@field(v, field.name));
            try self.set_named_property(res, field.name ++ "", tmp_val);
        }
    }

    pub fn get_object(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: T = undefined;
        inline for (std.meta.fields(T)) |field| {
            var tmp_val = try self.get_named_property(v, field.name ++ "");
            @field(res, field.name) = try self.parse(field.type, tmp_val);
        }
        return res;
    }

    pub fn set_named_property(self: *JSCtx, obj: napi.napi_value, key: [*:0]const u8, v: napi.napi_value) Error!void {
        try err_check(napi.napi_set_named_property(self.env, obj, key, v));
    }

    pub fn get_named_property(self: *JSCtx, obj: napi.napi_value, key: [*:0]const u8) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_named_property(self.env, obj, key, &res));
        return res;
    }

    pub fn wrap_object(self: *JSCtx, v: anytype) Error!napi.napi_value {
        // no wrapping fn pointer as object
        if (comptime trait.isPtrTo(.Fn)(@TypeOf(v))) @compileError("use create_function() to export fn");
        var res: napi.napi_value = undefined;
        if (self.refs.get(@ptrToInt(v))) |r| {
            if (napi.napi_get_reference_value(self.env, r, &res) == napi.napi_ok) {
                return res;
            } else {
                _ = napi.napi_delete_reference(self.env, r);
            }
        }
        var ref: napi.napi_ref = undefined;
        res = try self.create_object();
        try err_check(napi.napi_wrap(self.env, res, @constCast(v), &delete_ref, @ptrCast(*anyopaque, @constCast(v)), &ref));
        try self.refs.put(allocator, @ptrToInt(v), ref);
        return res;
    }

    pub fn unwrap_object(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!*T {
        var res: *T = undefined;
        try err_check(napi.napi_unwrap(self.env, v, @ptrCast([*c]?*anyopaque, &res)));
        return res;
    }

    fn delete_ref(env: napi.napi_env, _: ?*anyopaque, ptr: ?*anyopaque) callconv(.C) void {
        var ctx = JSCtx.get_instance(env);
        const ptr_int = @ptrToInt(ptr.?);
        if (ctx.refs.get(ptr_int)) |r| {
            var v: napi.napi_value = undefined;
            // if reference is valid/new, return early
            if (napi.napi_get_reference_value(env, r, &v) == napi.napi_ok) return;
            _ = napi.napi_delete_reference(env, r);
            _ = ctx.refs.remove(ptr_int);
        }
    }

    pub fn create_function(self: *JSCtx, comptime func: anytype, comptime name: []const u8) Error!napi.napi_value {
        const F = @TypeOf(func);
        const Args = std.meta.ArgsTuple(F);
        const Res = @typeInfo(F).Fn.return_type.?;

        // TODO: need to pass fn name as arg to `call` fn
        const FnUtils = struct {
            pub const fn_name = name;

            fn call(env: napi.napi_env, cb: napi.napi_callback_info) callconv(.C) napi.napi_value {
                var ctx = JSCtx.get_instance(env);
                const args = read_args(ctx, cb) catch |err| return ctx.create_error(err);
                const res = @call(.auto, func, args);
                if (comptime trait.is(.ErrorUnion)(Res)) {
                    return if (res) |r| ctx.write(r, fn_name) catch |err| ctx.create_error(err) else |err| ctx.create_error(err);
                } else {
                    return ctx.write(res, fn_name) catch |err| ctx.create_error(err);
                }
            }

            fn read_args(ctx: *JSCtx, cb: napi.napi_callback_info) Error!Args {
                var args: Args = undefined;
                var arg_count: usize = args.len;
                var arg_values: [args.len]napi.napi_value = undefined;
                try err_check(napi.napi_get_cb_info(ctx.env, cb, &arg_count, &arg_values, null, null));
                var i: usize = 0;
                inline for (std.meta.fields(Args)) |field| {
                    if (comptime field.type == *JSCtx) {
                        @field(args, field.name) = ctx;
                        continue;
                    }
                    @field(args, field.name) = try ctx.parse(field.type, arg_values[i], fn_name);
                    i += 1;
                }
                if (i != arg_count) {
                    std.debug.print("expected {d} args\n", .{arg_count});
                    return error.InvalidArgumentCount;
                }
                return args;
            }
        };

        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_function(self.env, "", napi.NAPI_AUTO_LENGTH, &FnUtils.call, null, &res));
        return res;
    }

    pub fn call_function(self: *JSCtx, r: napi.napi_value, func: napi.napi_value, args: anytype) Error!napi.napi_value {
        const Args = @TypeOf(args);
        var arg_values: [std.meta.fields(Args).len]napi.napi_value = undefined;
        inline for (std.meta.fields(Args), 0..) |field, i| {
            arg_values[i] = try self.write(@field(args, field.name), "");
        }
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_call_function(self.env, r, func, arg_values.len, &arg_values, &res));
        return res;
    }

    // TODO: integrate into the default handler?
    pub fn create_external(self: *JSCtx, v: *anyopaque, finalizer: napi.napi_finalize, hint: ?*anyopaque) Error!napi.napi_value {
        if (comptime trait.isPtrTo(.Fn)(@TypeOf(v))) @compileError("use create_function() to export fn");
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_external(self.env, v, finalizer, hint, &res));
        return res;
    }

    pub fn get_external(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: T = undefined;
        try err_check(napi.napi_get_value_external(self.env, v, &res));
        return res;
    }

    // TODO: create/get `ArrayBuffer`

    // TODO: create/get `Buffer`
    pub fn create_buffer(self: *JSCtx, v: []const u8) Error!napi.napi_value {
        var data: ?*anyopaque = undefined;
        var res: napi.napi_value = undefined;
        // let v8 allocate buffer and copy mem over
        try err_check(napi.napi_create_buffer(self.env, v.len, &data, &res));
        std.mem.copy(u8, @ptrCast([*]u8, data.?)[0..v.len], v[0..v.len]);
        return res;
    }

    /// Returns data from `node::Buffer` as slice.
    pub fn get_buffer_as_slice(self: *JSCtx, v: napi.napi_value) Error![]u8 {
        var res: ?*anyopaque = null;
        var len: usize = undefined;
        try err_check(napi.napi_get_buffer_info(self.env, v, &res, &len));
        return @ptrCast([*]u8, res.?)[0..len];
    }

    pub fn get_buffer(self: *JSCtx, v: napi.napi_value) Error![*c]u8 {
        var res: ?*anyopaque = null;
        var len: usize = undefined;
        try err_check(napi.napi_get_buffer_info(self.env, v, &res, &len));
        return @ptrCast([*c]u8, res.?);
    }

    // TODO: create/get `TypedArray`
    pub fn get_typed_array_length(self: *JSCtx, v: napi.napi_value) Error!usize {
        var len: usize = undefined;
        try err_check(napi.napi_get_typedarray_info(self.env, v, null, &len, null, null, null));
        return len;
    }

    pub fn get_typed_array_data(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: ?*anyopaque = undefined;
        var len: usize = undefined;
        try err_check(napi.napi_get_typedarray_info(self.env, v, null, &len, &res, null, null));
        return @ptrCast(T, @alignCast(@alignOf(T), res.?));
    }
};
