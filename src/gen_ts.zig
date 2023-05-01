const std = @import("std");
const root = @import("root");

pub const FnArgs = struct {
    name: []const u8,
    mapped_type: ?[]const u8 = null,
    skip: bool = false,
};

pub const FnInfo = struct { args: []FnArgs, returns: ?FnReturns = null };

pub const FnReturns = struct { mapped_type: []const u8 };

pub const TSExports = struct {
    arena: std.heap.ArenaAllocator,
    buffer: std.ArrayList(u8),

    pub const parse = if (@hasDecl(root, "custom_arg_parser")) root.custom_arg_parser else arg_parser;
    pub fn arg_parser(_: *TSExports, comptime T: type, _: []const u8) ![]const u8 {
        if (comptime T == []const u8) return "string";

        return switch (@typeInfo(T)) {
            .Void => void{},
            .Null => "null",
            .Bool => "boolean",
            .Int, .ComptimeInt, .Float, .ComptimeFloat => {
                return switch (T) {
                    u8, u16, u32, c_uint, i8, i16, i32, c_int, f16, f32, f64 => "number",
                    u64, usize, i64, isize => "bigint",
                    else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                };
            },
            // TODO: validate this works
            .Enum => |info| return info.decls.name,
            // TODO: handle structs
            // .Struct => if (trait.isTuple(T)) self.get_tuple(T, v) else self.get_object(T, v),
            // TODO: handle optionals
            // .Optional => |info| if (try self.type_of(v) == napi.napi_null) null else self.parse(info.child, v, ""),
            // TODO: handle arrays
            // .Array => return "",
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => |info| switch (info.size) {
                // TODO: either leverage mapped type or find smarter solution to link to relevant JS type
                .One => "any",
                .C => {
                    // if JS `TypedArray` equivalent exists, handle as such
                    const data_type = info.child;
                    return switch (data_type) {
                        f32 => "Float32Array",
                        f64 => "Float64Array",
                        i8 => "Int8Array",
                        i16 => "Int16Array",
                        i32 => "Int32Array",
                        i64 => "BigInt64Array",
                        u8 => "Uint8Array",
                        u16 => "Uint16Array",
                        u32 => "Uint32Array",
                        u64 => "BigUint64Array",
                        else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                    };
                },
                .Slice => {
                    const data_type = info.child;
                    return switch (data_type) {
                        f32 => "Float32Array",
                        f64 => "Float64Array",
                        i8 => "Int8Array",
                        i16 => "Int16Array",
                        i32 => "Int32Array",
                        i64 => "BigInt64Array",
                        u8 => "Uint8Array",
                        u16 => "Uint16Array",
                        u32 => "Uint32Array",
                        u64 => "BigUint64Array",
                        else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                    };
                },
                else => @compileError("reading " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
            },
            else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    pub const write = if (@hasDecl(root, "custom_return_handler")) root.custom_return_handler else return_handler;
    pub fn return_handler(self: *TSExports, comptime T: type, _: []const u8) ![]const u8 {
        _ = self;
        // coercion to string needs to be done in wrapped fn
        if (comptime T == []const u8) return "string";

        return switch (@typeInfo(T)) {
            .Void => "void",
            .Null => "null",
            .Bool => "boolean",
            .Int, .ComptimeInt, .Float, .ComptimeFloat => {
                return switch (T) {
                    u8, u16, u32, c_uint, i8, i16, i32, c_int, f16, f32, f64 => "number",
                    u64, usize, i64, isize => "bigint",
                    else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                };
            },
            // TODO: validate this works
            .Enum => |info| return info.decls.name,
            // TODO: handle structs
            // .Struct => if (trait.isTuple(T)) self.create_tuple(v) else self.create_object_from(v),
            // TODO: handle optionals
            // .Optional => if (v) |val| self.write(val, "") else self.null(),
            // TODO: handle arrays
            // .Array => return "",
            // TODO: better handling of pointers (not always going to leverage `wrap_object`)
            .Pointer => |info| switch (info.size) {
                // TODO: either leverage mapped type or find smarter solution to link to relevant JS type
                .One => "any",
                .C => {
                    // if JS `TypedArray` equivalent exists, handle as such
                    const data_type = info.child;
                    return switch (data_type) {
                        f32 => "Float32Array",
                        f64 => "Float64Array",
                        i8 => "Int8Array",
                        i16 => "Int16Array",
                        i32 => "Int32Array",
                        i64 => "BigInt64Array",
                        u8 => "Uint8Array",
                        u16 => "Uint16Array",
                        u32 => "Uint32Array",
                        u64 => "BigUint64Array",
                        else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                    };
                },
                .Slice => {
                    const data_type = info.child;
                    return switch (data_type) {
                        f32 => "Float32Array",
                        f64 => "Float64Array",
                        i8 => "Int8Array",
                        i16 => "Int16Array",
                        i32 => "Int32Array",
                        i64 => "BigInt64Array",
                        u8 => "Uint8Array",
                        u16 => "Uint16Array",
                        u32 => "Uint32Array",
                        u64 => "BigUint64Array",
                        else => @compileError("parsing " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
                    };
                },
                else => @compileError("returning " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
            },
            else => @compileError("returning " ++ @tagName(@typeInfo(T)) ++ " " ++ @typeName(T) ++ " is not supported"),
        };
    }

    pub fn init() !*TSExports {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var allocator = arena.allocator();
        var self = try allocator.create(TSExports);
        var buffer = std.ArrayList(u8).init(allocator);
        self.* = .{
            .arena = arena,
            .buffer = buffer,
        };
        return self;
    }

    pub fn deinit(self: *TSExports) void {
        self.arena.deinit();
    }

    pub fn write_frontmatter(self: *TSExports, import_path: []const u8, frontmatter: []const u8) !void {
        // write file frontmatter
        try self.buffer.writer().print(
            \\///////////////////////////////////////////////////////
            \\// This file was auto-generated by zig-bindgen-js    //
            \\//              Do not manually modify.              //
            \\///////////////////////////////////////////////////////
            \\const addon = import.meta.require('{s}');
            \\
            \\{s}
        , .{ import_path, frontmatter });
    }

    pub fn wrap_method(self: *TSExports, comptime name: []const u8, comptime func: anytype, comptime info: FnInfo) !void {
        const F = @TypeOf(func);
        const Args = std.meta.ArgsTuple(F);
        const Res = @typeInfo(F).Fn.return_type.?;
        const ArgFields = @typeInfo(Args).Struct.fields;
        try self.buffer.writer().print("export const {s} = (", .{name});
        inline for (info.args, 0..) |arg, i| {
            if (arg.skip) continue;
            // const ts_type: []const u8 = if (arg.mapped_type != null) arg.mapped_type else try self.parse(ArgFields[i].type, name);
            const ts_type: []const u8 = try self.parse(ArgFields[i].type, name);
            const arg_name: []const u8 = arg.name;
            if (i != 0) {
                try self.buffer.appendSlice(" ");
            }
            try self.buffer.writer().print("{s}: {s}", .{ arg_name, ts_type });
            if (i != info.args.len - 1) {
                try self.buffer.appendSlice(",");
            }
        }
        const res_type: []const u8 = if (info.returns != null) info.returns.mapped_type else try self.write(Res, name);
        try self.buffer.writer().print("): {s} => {{\n", .{res_type});
        try self.buffer.writer().print("\treturn addon.{s}(", .{name});
        inline for (info.args, 0..) |arg, i| {
            if (arg.skip) continue;
            if (i != 0) {
                try self.buffer.appendSlice(" ");
            }
            try self.buffer.writer().print("{s}", .{arg.name});
            if (i != info.args.len - 1) {
                try self.buffer.appendSlice(",");
            }
        }
        try self.buffer.writer().print(");\n}}\n\n", .{});
    }

    pub fn write_wrapper(self: *TSExports, out_path: []const u8) !void {
        try std.fs.cwd().writeFile(out_path, self.buffer.items);
    }
};
