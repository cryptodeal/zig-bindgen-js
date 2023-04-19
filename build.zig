const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "zig-bindgen-js",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // weak-linkage
    lib.linker_allow_shlib_undefined = true;
    // lib.addAnonymousModule("napigen", .{ .source_file = .{ .path = "libs/zig-napigen/napigen.zig" } });
    lib.addLibraryPath(".");
    lib.addRPath(".");
    lib.linkSystemLibrary("flashlight_binding");
    lib.addIncludePath("cpp");
    lib.addIncludePath("libs/napi-headers/include");
    lib.linkLibC();
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
    b.installLibFile(b.pathJoin(&.{ "zig-out/lib", lib.out_lib_filename }), "example.node");

    // Creates a step for unit testing.
    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linker_allow_shlib_undefined = true;
    main_tests.addAnonymousModule("napigen", .{ .source_file = .{ .path = "libs/zig-napigen/napigen.zig" } });
    main_tests.addLibraryPath(".");
    main_tests.addRPath(".");
    main_tests.linkSystemLibrary("flashlight_binding");
    main_tests.addIncludePath("cpp");
    main_tests.linkLibC();
    main_tests.linkLibCpp();

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build test`
    // This will evaluate the `test` step rather than the default, which is "install".
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
