const std = @import("std");
const c = @import("c.zig");
const napi_utils = @import("napi_utils.zig");
const fl = @cImport({
    @cInclude("flashlight_binding.h");
});

export fn napi_register_module_v1(env: c.napi_env, exports: c.napi_value) c.napi_value {
    napi_utils.register_function(env, exports, "bytesUsed", bytesUsed) catch return null;
    return exports;
}

fn bytesUsed(env: c.napi_env, info: c.napi_callback_info) callconv(.C) c.napi_value {
    _ = info;
    var result: c.napi_value = undefined;
    if (c.napi_create_int64(env, @bitCast(i64, fl.bytesUsed()), &result) != c.napi_ok) {
        napi_utils.throw(env, "Failed to get args.") catch return null;
    }

    return result;
}
