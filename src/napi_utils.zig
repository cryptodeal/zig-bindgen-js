const c = @import("c.zig");

pub fn register_function(
    env: c.napi_env,
    exports: c.napi_value,
    comptime name: [:0]const u8,
    comptime function: fn (env: c.napi_env, info: c.napi_callback_info) callconv(.C) c.napi_value,
) !void {
    var napi_function: c.napi_value = undefined;
    if (c.napi_create_function(env, null, 0, function, null, &napi_function) != c.napi_ok) {
        return throw(env, "Failed to create function " ++ name ++ "().");
    }

    if (c.napi_set_named_property(env, exports, name, napi_function) != c.napi_ok) {
        return throw(env, "Failed to add " ++ name ++ "() to exports.");
    }
}

const ConversionError = error{ExceptionThrown};
pub fn throw(env: c.napi_env, comptime message: [:0]const u8) ConversionError {
    var result = c.napi_throw_error(env, null, message);
    switch (result) {
        c.napi_ok, c.napi_pending_exception => {},
        else => unreachable,
    }

    return ConversionError.ExceptionThrown;
}

pub fn get_undefined(env: c.napi_env) !c.napi_value {
    var result: c.napi_value = undefined;
    if (c.napi_get_undefined(env, &result) != c.napi_ok) {
        return throw(env, "Failed to get the value of \"undefined\".");
    }

    return result;
}

pub fn set_instance_data(
    env: c.napi_env,
    data: *anyopaque,
    finalize_callback: fn (env: c.napi_env, data: ?*anyopaque, hint: ?*anyopaque) callconv(.C) void,
) !void {
    if (c.napi_set_instance_data(env, data, finalize_callback, null) != c.napi_ok) {
        return throw(env, "Failed to initialize env.");
    }
}

pub fn create_external(env: c.napi_env, context: *anyopaque) !c.napi_value {
    var result: c.napi_value = null;
    if (c.napi_create_external(env, context, null, null, &result) != c.napi_ok) {
        return throw(env, "Failed to create external for client context.");
    }

    return result;
}

pub fn get_value_external(
    env: c.napi_env,
    value: c.napi_value,
    comptime error_message: [:0]const u8,
) !?*anyopaque {
    var result: ?*anyopaque = undefined;
    if (c.napi_get_value_external(env, value, &result) != c.napi_ok) {
        return throw(env, error_message);
    }

    return result;
}
