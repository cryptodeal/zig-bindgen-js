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

/// translates Node-API `napi_status` enum to relevant `Error` type
pub fn err_check(status: napi.napi_status) Error!void {
    if (status != napi.napi_ok) {
        inline for (comptime std.meta.fieldNames(NapiErrorTypes)) |err| {
            if (status == @field(napi, err)) return @field(NapiErrorTypes, err);
        } else @panic("unknown napi error type");
    }
}

/// utility for defining Node-API exports at comptime
pub fn define_module(comptime init: fn (*JSCtx, napi.napi_value) Error!napi.napi_value) void {
    const NapiModule = struct {
        fn register(env: napi.napi_env, exports: napi.napi_value) callconv(.C) napi.napi_value {
            var ctx = JSCtx.init(env) catch @panic("failed to init JS context");
            return init(ctx, exports) catch |err| ctx.create_error(err);
        }
    };
    @export(NapiModule.register, .{ .name = "napi_register_module_v1", .linkage = .Strong });
}

const TransientAllocator = struct {
    count: u32 = 0,
    backing_alloc: std.heap.ArenaAllocator,

    pub fn init(backing_allocator: std.mem.Allocator) TransientAllocator {
        return .{
            .backing_alloc = std.heap.ArenaAllocator.init(backing_allocator),
        };
    }

    pub fn deinit(self: *TransientAllocator) void {
        self.backing_alloc.deinit();
    }

    pub fn allocator(self: *TransientAllocator) std.mem.Allocator {
        return self.backing_alloc.allocator();
    }

    pub fn inc(self: *TransientAllocator) void {
        self.count += 1;
    }

    pub fn dec(self: *TransientAllocator) void {
        self.count -= 1;
        if (self.count == 0) {
            _ = self.backing_alloc.reset(.retain_capacity);
        }
    }
};

// TODO: potentially useful to provide addtl context about function call
pub const FnCtx = struct {
    name: []const u8,
    len: *usize,
    alloc: std.heap.ArenaAllocator = undefined,
};

const WrappedCtx = struct {
    size: usize,
    alignment: u8,
};

pub const JSCtx = struct {
    env: napi.napi_env,
    refs: std.AutoHashMapUnmanaged(usize, napi.napi_ref) = .{},
    mem: TransientAllocator,

    // parse hook (handles conversion: JS -> Native)
    pub const parse = if (@hasDecl(root, "custom_arg_parser")) root.custom_arg_parser else arg_parser;
    pub fn arg_parser(self: *JSCtx, comptime T: type, v: napi.napi_value, comptime ctx: FnCtx) Error!T {
        if (T == napi.napi_value) return v;
        if (comptime T == []const u8) return self.get_string(v);

        return switch (@typeInfo(T)) {
            .Void => void{},
            .Null => null,
            .Bool => self.get_boolean(v),
            .Int, .ComptimeInt, .Float, .ComptimeFloat => self.get_number(T, v),
            .Enum => std.meta.intToEnum(T, self.get_number(u32, v)),
            .Struct => if (trait.isTuple(T)) self.get_tuple(T, v, ctx) else self.get_object(T, v, ctx),
            .Optional => |info| if (try self.type_of(v) == napi.napi_null) null else self.parse(info.child, v, ctx),
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => |info| switch (info.size) {
                // handle by wrapping as user must define finalizer for `Napi::External` via hooks
                .One => self.unwrap_object(info.child, v),
                .C => {
                    // if JS `TypedArray` equivalent exists, handle as such
                    const data_type = info.child;
                    return switch (data_type) {
                        f32, f64, i8, i16, i32, i64, u8, u16, u32, u64 => self.get_typedarray_data(data_type, v),
                        else => (try self.get_array(data_type, v, ctx)).ptr,
                    };
                },
                .Slice => {
                    const data_type = info.child;
                    return switch (data_type) {
                        f32, f64, i8, i16, i32, i64, u8, u16, u32, u64 => {
                            const len = try self.get_typedarray_length(v);
                            return (try self.get_typedarray_data(data_type, v))[0..len];
                        },
                        else => self.get_array(data_type, v, ctx),
                    };
                },
                else => @compileError("reading " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
            },
            else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    // write hook (handles conversion: Native -> JS)
    pub const write = if (@hasDecl(root, "custom_return_handler")) root.custom_return_handler else return_handler;
    pub fn return_handler(self: *JSCtx, v: anytype, comptime ctx: FnCtx) Error!napi.napi_value {
        const T = @TypeOf(v);
        if (comptime T == napi.napi_value) return v;
        // coercion to string needs to be done in wrapped fn
        if (comptime T == []const u8) return self.create_string(v);

        return switch (@typeInfo(T)) {
            .Void => self.undefined(),
            .Null => self.null(),
            .Bool => self.create_boolean(v),
            .Int, .ComptimeInt, .Float, .ComptimeFloat => self.create_number(v),
            .Enum => self.create_number(@as(u32, @enumToInt(v))),
            .Struct => if (trait.isTuple(T)) self.create_tuple(v, ctx) else self.create_object_from(v, ctx),
            .Optional => if (v) |val| self.write(val, ctx) else self.null(),
            // TODO: fix Array handling
            .Array => |info| {
                const data_type = info.child;
                return switch (data_type) {
                    f32, f64, i8, i16, i32, i64, u8, u16, u32, u64 => {
                        var slice = v[0..v.len];
                        return self.create_typedarray(data_type, slice);
                    },
                    else => self.create_array_from(v, ctx),
                };
            },
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => |info| switch (info.size) {
                .One => self.wrap_object(v),
                .C => {
                    // if JS `TypedArray` equivalent exists, handle as such
                    const data_type = info.child;
                    return switch (data_type) {
                        f32, f64, i8, i16, i32, i64, u8, u16, u32, u64 => self.create_typedarray(data_type, v[0..ctx.len.*]),
                        else => self.create_array_from(v, ctx),
                    };
                },
                // TODO: handle `Many` pointer case
                // .Many => {},
                .Slice => {
                    const data_type = info.child;
                    return switch (data_type) {
                        f32, f64, i8, i16, i32, i64, u8, u16, u32, u64 => {
                            return self.create_typedarray(data_type, v);
                        },
                        else => self.create_array_from(v, ctx),
                    };
                },
                else => @compileError("returning " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
            },
            else => @compileError("returning " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    /// initialize new JSCtx instance
    pub fn init(env: napi.napi_env) Error!*JSCtx {
        var self = try allocator.create(JSCtx);
        try err_check(napi.napi_set_instance_data(env, self, finalize, null));
        self.* = .{
            .env = env,
            .mem = TransientAllocator.init(allocator),
        };
        return self;
    }

    /// deinitialize the JSCtx instance
    pub fn deinit(self: *JSCtx) void {
        self.mem.deinit();
        allocator.destroy(self);
    }

    /// get `JSCtx` instance from Node-API `env`
    fn get_instance(env: napi.napi_env) *JSCtx {
        var res: *JSCtx = undefined;
        err_check(napi.napi_get_instance_data(env, @ptrCast([*c]?*anyopaque, &res))) catch @panic("could not get JS context");
        return res;
    }

    fn finalize(env: napi.napi_env, _: ?*anyopaque, _: ?*anyopaque) callconv(.C) void {
        get_instance(env).deinit();
    }

    /// get type of JS value
    fn type_of(self: *JSCtx, v: napi.napi_value) Error!napi.napi_valuetype {
        var res: napi.napi_valuetype = undefined;
        try err_check(napi.napi_typeof(self.env, v, &res));
        return res;
    }

    /// throws napi builtin error types
    pub fn create_error(self: *JSCtx, err: anyerror) napi.napi_value {
        const msg = @ptrCast([*c]const u8, @errorName(err));
        err_check(napi.napi_throw_error(self.env, null, msg)) catch |e| {
            if (e != error.napi_pending_exception) std.debug.panic("throw failed {s} {any}", .{ msg, e });
        };
        return self.undefined() catch @panic("throw return undefined");
    }

    // TODO: use this to throw errors w custom messages
    pub fn throw(self: *JSCtx, comptime message: [:0]const u8) ConversionError {
        var result = napi.napi_throw_error(self.env, null, message);
        switch (result) {
            napi.napi_ok, napi.napi_pending_exception => {},
            else => unreachable,
        }
        return ConversionError.ExceptionThrown;
    }

    // get JS `undefined`
    pub fn @"undefined"(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_undefined(self.env, &res));
        return res;
    }

    /// get JS `null`
    pub fn @"null"(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_null(self.env, &res));
        return res;
    }

    /// transform `bool` to JS `boolean`
    pub fn create_boolean(self: *JSCtx, v: bool) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_boolean(self.env, v, &res));
        return res;
    }

    /// parse JS `boolean` to `bool`
    pub fn get_boolean(self: *JSCtx, v: napi.napi_value) Error!bool {
        var res: bool = undefined;
        try err_check(napi.napi_get_value_bool(self.env, v, &res));
        return res;
    }

    /// transform `T` (where `T` is native number type) to JS `number` or `bigint`
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

    /// parse JS `number` or `bigint` to `T` (where `T` is native number type)
    pub fn get_number(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: T = undefined;
        // TODO: throw error if unable to convert losslessly
        var loss: bool = undefined;
        switch (T) {
            u8, u16 => res = @truncate(T, try self.get_number(u32, v)),
            u32, c_uint => try err_check(napi.napi_get_value_uint32(self.env, v, &res)),
            u64, usize => try err_check(napi.napi_get_value_bigint_uint64(self.env, v, &res, &loss)),
            i8, i16 => res = @truncate(T, try self.get_number(i32, v)),
            i32, c_int => try err_check(napi.napi_get_value_int32(self.env, v, &res)),
            i64, isize => try err_check(napi.napi_get_value_bigint_int64(self.env, v, &res, &loss)),
            f16, f32 => res = @floatCast(T, try self.get_number(f64, v)),
            f64 => try err_check(napi.napi_get_value_double(self.env, v, &res)),
            else => @compileError(@typeName(T) ++ " is not supported number"),
        }
        return res;
    }

    /// transform `[]const u8` to JS `string`
    pub fn create_string(self: *JSCtx, v: []const u8) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_string_utf8(self.env, @ptrCast([*c]const u8, v), v.len, &res));
        return res;
    }

    /// get length of JS `string`
    pub fn get_string_length(self: *JSCtx, v: napi.napi_value) Error!usize {
        var res: usize = undefined;
        try err_check(napi.napi_get_value_string_utf8(self.env, v, null, 0, &res));
        return res;
    }

    /// parse JS `string` to `[]const u8`
    pub fn get_string(self: *JSCtx, v: napi.napi_value) Error![]const u8 {
        var len: usize = undefined;
        try err_check(napi.napi_get_value_string_utf8(self.env, v, null, 0, &len));
        var buf = try self.mem.allocator().alloc(u8, len + 1);
        try err_check(napi.napi_get_value_string_utf8(self.env, v, @ptrCast([*c]u8, buf), buf.len, &len));
        return buf[0..len];
    }

    /// creates new (empty) JS `Array` (equivalent to `[]` in JS)
    pub fn create_array(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_array(self.env, &res));
        return res;
    }

    /// create JS `Array` with given length (equivalent to calling `new Array(len)` in JS)
    pub fn create_array_with_length(self: *JSCtx, len: u32) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_array_with_length(self.env, len, &res));
        return res;
    }

    /// transform native array/slice to JS `Array` (if no compatible `TypedArray` exists)
    pub fn create_array_from(self: *JSCtx, v: anytype, comptime ctx: FnCtx) Error!napi.napi_value {
        const res = try self.create_array_with_length(@truncate(u32, v.len));
        for (v, 0..) |val, i| {
            try self.set_element(res, @truncate(u32, i), try self.write(val, ctx));
        }
        return res;
    }

    /// get length (u32) of JS `Array`
    pub fn get_array_length(self: *JSCtx, v: napi.napi_value) Error!u32 {
        var res: u32 = undefined;
        try err_check(napi.napi_get_array_length(self.env, v, &res));
        return res;
    }

    /// parse JS Array to native slice.
    pub fn get_array(self: *JSCtx, comptime T: type, arr: napi.napi_value, comptime ctx: FnCtx) Error![]T {
        var len: u32 = try self.get_array_length(arr);
        var res = try self.mem.allocator().alloc(T, len);
        for (res, 0..) |*v, i| {
            v.* = try self.parse(T, try self.get_element(arr, @intCast(u32, i)), ctx);
        }
        return res;
    }

    /// get value in JS `Array` at index `i`
    pub fn get_element(self: *JSCtx, v: napi.napi_value, i: u32) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_element(self.env, v, i, &res));
        return res;
    }

    /// set value in JS `Array` at index `i`
    pub fn set_element(self: *JSCtx, array: napi.napi_value, i: u32, v: napi.napi_value) Error!void {
        try err_check(napi.napi_set_element(self.env, array, i, v));
    }

    /// transform `tuple` to JS `[T1, T2... etc]`
    pub fn create_tuple(self: *JSCtx, v: anytype, comptime ctx: FnCtx) Error!napi.napi_value {
        const fields = std.meta.fields(@TypeOf(v));
        var res = try self.create_array_with_length(fields.len);
        inline for (fields, 0..) |field, i| {
            var tmp_val = try self.write(@field(v, field.name), ctx);
            try self.set_element(res, @truncate(u32, i), tmp_val);
        }
        return res;
    }

    /// parse JS `[T1, T2... etc]` to `tuple`
    pub fn get_tuple(self: *JSCtx, comptime T: type, v: napi.napi_value, comptime ctx: FnCtx) Error!T {
        const fields = std.meta.fields(T);
        var res: T = undefined;
        inline for (fields, 0..) |field, i| {
            var tmp_val = try self.get_element(v, @truncate(u32, i));
            @field(res, field.name) = try self.parse(field.type, tmp_val, ctx);
        }
        return res;
    }

    /// creates new (empty) JS `Object` (equivalent to `{}` in JS)
    pub fn create_object(self: *JSCtx) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_object(self.env, &res));
        return res;
    }

    /// transform `struct` to JS `Object`
    pub fn create_object_from(self: *JSCtx, v: anytype, comptime ctx: FnCtx) Error!napi.napi_value {
        var res: napi.napi_value = try self.create_object();
        inline for (std.meta.fields(@TypeOf(v))) |field| {
            var tmp_val = try self.write(@field(v, field.name), ctx);
            try self.set_named_property(res, field.name ++ "", tmp_val);
        }

        return res;
    }

    /// parse `struct` from JS `Object`
    pub fn get_object(self: *JSCtx, comptime T: type, v: napi.napi_value, comptime ctx: FnCtx) Error!T {
        var res: T = undefined;
        inline for (std.meta.fields(T)) |field| {
            var tmp_val = try self.get_named_property(v, field.name ++ "");
            @field(res, field.name) = try self.parse(field.type, tmp_val, ctx);
        }
        return res;
    }

    /// set value at key (`string`) in JS `Object`
    pub fn set_named_property(self: *JSCtx, obj: napi.napi_value, key: [*:0]const u8, v: napi.napi_value) Error!void {
        try err_check(napi.napi_set_named_property(self.env, obj, key, v));
    }

    /// retrieve value at key (`string`) in JS `Object`
    pub fn get_named_property(self: *JSCtx, obj: napi.napi_value, key: [*:0]const u8) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_get_named_property(self.env, obj, key, &res));
        return res;
    }

    /// transform `*T` to JS `ObjectWrap<T>`
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
        std.debug.print("attempt wrap object\n", .{});
        const T = @TypeOf(v);
        const hint = WrappedCtx{
            .size = comptime @sizeOf(T),
            .alignment = comptime @alignOf(T),
        };
        try err_check(napi.napi_wrap(self.env, res, @constCast(v), &delete_ref, @ptrCast(*anyopaque, @alignCast(hint.alignment, @constCast(&hint))), &ref));
        try self.refs.put(allocator, @ptrToInt(v), ref);
        return res;
    }

    /// parse JS `ObjectWrap<T>` to `*T`
    pub fn unwrap_object(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!*T {
        var res: *T = undefined;
        try err_check(napi.napi_unwrap(self.env, v, @ptrCast([*c]?*anyopaque, &res)));
        return res;
    }

    fn delete_ref(env: napi.napi_env, ptr: ?*anyopaque, hint: ?*anyopaque) callconv(.C) void {
        const finalizer_ctx = @ptrCast(*WrappedCtx, @alignCast(@alignOf(*WrappedCtx), hint.?));
        var ctx = JSCtx.get_instance(env);
        const ptr_int = @ptrToInt(ptr.?);
        // TODO: verify this worked to free allocated mem from wrapped struct
        allocator.rawFree(@ptrCast([*]u8, ptr.?)[0..finalizer_ctx.size], finalizer_ctx.alignment, @returnAddress());
        if (ctx.refs.get(ptr_int)) |r| {
            var v: napi.napi_value = undefined;
            // if reference is valid/new, return early
            if (napi.napi_get_reference_value(env, r, &v) == napi.napi_ok) return;
            _ = napi.napi_delete_reference(env, r);
            _ = ctx.refs.remove(ptr_int);
        }
    }
    /// Create a JS function.
    pub fn create_function(self: *JSCtx, comptime func: anytype) Error!napi.napi_value {
        return self.create_named_function("anonymous", func);
    }

    /// creates JS function
    pub fn create_named_function(self: *JSCtx, comptime name: []const u8, comptime func: anytype) Error!napi.napi_value {
        // TODO: add hook (scoped to fn call?) here to capture length of returned C array
        const F = @TypeOf(func);
        const Args = std.meta.ArgsTuple(F);
        const Res = @typeInfo(F).Fn.return_type.?;

        // TODO: need to pass fn name as arg to `call` fn
        const FnUtils = struct {
            var c_array_len: usize = 0;
            const fn_ctx = FnCtx{ .name = name, .len = &c_array_len };

            fn call(env: napi.napi_env, cb: napi.napi_callback_info) callconv(.C) napi.napi_value {
                var ctx = JSCtx.get_instance(env);
                ctx.mem.inc();
                // free any temp allocated mem after fn call
                defer ctx.mem.dec();
                const args = read_args(ctx, cb) catch |err| return ctx.create_error(err);
                const res = @call(.auto, func, args);

                if (comptime trait.is(.ErrorUnion)(Res)) {
                    return if (res) |r| ctx.write(r, fn_ctx) catch |err| ctx.create_error(err) else |err| ctx.create_error(err);
                } else {
                    return ctx.write(res, fn_ctx) catch |err| ctx.create_error(err);
                }
            }

            fn read_args(ctx: *JSCtx, cb: napi.napi_callback_info) Error!Args {
                var args: Args = undefined;
                var arg_count: usize = args.len;
                var arg_values: [args.len]napi.napi_value = undefined;
                try err_check(napi.napi_get_cb_info(ctx.env, cb, &arg_count, &arg_values, null, null));

                const expected_arg_count = @typeInfo(Args).Struct.fields.len;
                var i: usize = 0;
                var real_count: usize = 0;
                inline for (std.meta.fields(Args)) |field| {
                    real_count += 1;
                    if (comptime field.type == std.mem.Allocator) {
                        // TODO: use below info to pass either ArenaAllocator or C_Allocator (avoid copy w finalizer)
                        switch (@typeInfo(Res)) {
                            .ErrorUnion => |e| {
                                switch (@typeInfo(e.payload)) {
                                    .Pointer => |info| {
                                        if (info.size == .One) {
                                            @field(args, field.name) = allocator;
                                        } else {
                                            @field(args, field.name) = ctx.mem.allocator();
                                        }
                                    },
                                    else => @field(args, field.name) = ctx.mem.allocator(),
                                }
                            },
                            else => @field(args, field.name) = ctx.mem.allocator(),
                        }
                        // @field(args, field.name) = ctx.mem.allocator();
                        continue;
                    }

                    if (comptime field.type == *JSCtx) {
                        @field(args, field.name) = ctx;
                        continue;
                    }

                    // hacky solution to snag length of C array ptr returned from fn
                    if (expected_arg_count != arg_count and field.type == [*c]usize) {
                        @field(args, field.name) = &c_array_len;
                    } else {
                        @field(args, field.name) = try ctx.parse(field.type, arg_values[i], fn_ctx);
                    }
                    i += 1;
                }

                if (real_count != expected_arg_count) {
                    std.debug.print("expected {d} args; received {d}\n", .{ arg_count, i });
                    return error.InvalidArgumentCount;
                }
                return args;
            }
        };

        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_function(self.env, "", napi.NAPI_AUTO_LENGTH, &FnUtils.call, null, &res));
        return res;
    }

    /// calls JS function
    pub fn call_function(self: *JSCtx, r: napi.napi_value, func: napi.napi_value, args: anytype) Error!napi.napi_value {
        const Args = @TypeOf(args);
        var arg_values: [std.meta.fields(Args).len]napi.napi_value = undefined;
        inline for (std.meta.fields(Args), 0..) |field, i| {
            arg_values[i] = try self.write(@field(args, field.name), FnCtx{ .name = "anonymous" });
        }
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_call_function(self.env, r, func, arg_values.len, &arg_values, &res));
        return res;
    }

    /// return `*T` as JS `External<T>`
    pub fn create_external(self: *JSCtx, v: *anyopaque, finalizer: napi.napi_finalize, hint: ?*anyopaque) Error!napi.napi_value {
        if (comptime trait.isPtrTo(.Fn)(@TypeOf(v))) @compileError("use create_function() to export fn");
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_external(self.env, v, finalizer, hint, &res));
        return res;
    }

    /// parse JS `External<T>` to `*T`
    pub fn get_external(self: *JSCtx, comptime T: type, v: napi.napi_value) Error!T {
        var res: T = undefined;
        try err_check(napi.napi_get_value_external(self.env, v, &res));
        return res;
    }
    // TODO: get `ArrayBuffer`
    pub fn create_arraybuffer(self: *JSCtx, comptime T: type, v: anytype) Error!napi.napi_value {
        const bytes = comptime @sizeOf(T);
        var data: ?*anyopaque = undefined;
        var res: napi.napi_value = undefined;
        const byte_len: usize = v.len * bytes;
        // TODO: avoid the copy?
        try err_check(napi.napi_create_arraybuffer(self.env, byte_len, &data, &res));
        std.mem.copy(T, @ptrCast([*]T, @alignCast(@alignOf(T), data.?))[0..v.len], v[0..v.len]);
        return res;
    }

    pub fn create_buffer(self: *JSCtx, v: []const u8) Error!napi.napi_value {
        var data: ?*anyopaque = undefined;
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_buffer(self.env, v.len, &data, &res));
        // TODO: avoid the copy?
        std.mem.copy(u8, @ptrCast([*]u8, data.?)[0..v.len], v[0..v.len]);
        return res;
    }

    /// transform `[]u8` slice to JS `Buffer` (copy/JS owns mem)
    pub fn create_buffer_copy(self: *JSCtx, v: []const u8) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        try err_check(napi.napi_create_buffer_copy(self.env, v.len, v.ptr, null, &res));
        return res;
    }

    /// parse JS `Buffer` to `[]u8` slice
    pub fn get_buffer_as_slice(self: *JSCtx, v: napi.napi_value) Error![]u8 {
        var res: ?*anyopaque = null;
        var len: usize = undefined;
        try err_check(napi.napi_get_buffer_info(self.env, v, &res, &len));
        return @ptrCast([*]u8, res.?)[0..len];
    }

    /// parse JS `Buffer` to `[*c]u8`
    pub fn get_buffer(self: *JSCtx, v: napi.napi_value) Error![*c]u8 {
        var res: ?*anyopaque = null;
        var len: usize = undefined;
        try err_check(napi.napi_get_buffer_info(self.env, v, &res, &len));
        return @ptrCast([*c]u8, res.?);
    }

    /// get length of JS `TypedArray`
    pub fn get_typedarray_length(self: *JSCtx, v: napi.napi_value) Error!usize {
        var len: usize = undefined;
        try err_check(napi.napi_get_typedarray_info(self.env, v, null, &len, null, null, null));
        return len;
    }

    /// parse JS `TypedArray` to relevant C Array (e.g. `Float32Array` -> `[*c]f32`)
    pub fn get_typedarray_data(self: *JSCtx, comptime T: type, v: napi.napi_value) Error![*]T {
        var res: ?*anyopaque = undefined;
        try err_check(napi.napi_get_typedarray_info(self.env, v, null, null, &res, null, null));
        return @ptrCast([*]T, @constCast(@alignCast(@alignOf([*]T), res.?)));
    }

    pub fn create_typedarray(self: *JSCtx, comptime T: type, v: anytype) Error!napi.napi_value {
        var res: napi.napi_value = undefined;
        const buf = try self.create_arraybuffer(T, v);
        try err_check(napi.napi_create_typedarray(self.env, get_napi_typedarray_type(T), v.len, buf, 0, &res));
        return res;
    }

    pub fn get_napi_typedarray_type(comptime T: type) napi.napi_typedarray_type {
        return switch (T) {
            f32 => napi.napi_float32_array,
            f64 => napi.napi_float64_array,
            i8 => napi.napi_int8_array,
            i16 => napi.napi_int16_array,
            i32 => napi.napi_int32_array,
            i64 => napi.napi_bigint64_array,
            u8 => napi.napi_uint8_array,
            u16 => napi.napi_uint16_array,
            u32 => napi.napi_uint32_array,
            u64 => napi.napi_biguint64_array,
            else => @compileError("unsupported type"),
        };
    }

    // TODO: create `TypedArray`
    // pub fn create_typedarray(self: *JSCtx, v: ?*anyopaque)
};
