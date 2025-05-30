const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build options
    const shared = b.option(bool, "shared", "Build as shared library") orelse false;
    const enable_testing = b.option(bool, "test", "Build tests for tinyxml2") orelse true;

    const upstream = b.dependency("upstream", .{});

    // Create the main library
    const lib = b.addLibrary(.{
        .name = "tinyxml2",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
        .linkage = if (shared) .dynamic else .static,
    });

    // Add source files
    lib.addCSourceFile(.{
        .file = upstream.path("tinyxml2.cpp"),
        .flags = &.{},
    });

    // Add header file
    lib.installHeadersDirectory(upstream.path("."), ".", .{
        .include_extensions = &.{".h"},
    });

    // Set C++ standard
    lib.linkLibCpp();

    // Compile definitions
    if (optimize == .Debug) {
        lib.root_module.addCMacro("TINYXML2_DEBUG", "");
    }

    if (shared) {
        lib.root_module.addCMacro("TINYXML2_EXPORT", "");
        // For consumers of the shared library
        lib.root_module.addCMacro("TINYXML2_IMPORT", "");
    }

    // Platform-specific definitions
    if (target.result.os.tag == .windows) {
        lib.root_module.addCMacro("_CRT_SECURE_NO_WARNINGS", "");
    }

    // Large file support
    lib.root_module.addCMacro("_FILE_OFFSET_BITS", "64");

    // Install the library
    b.installArtifact(lib);

    // Build tests if enabled
    if (enable_testing) {
        const xmltest = b.addExecutable(.{
            .name = "xmltest",
            .target = target,
            .optimize = optimize,
        });

        xmltest.addCSourceFile(.{
            .file = upstream.path("xmltest.cpp"),
            .flags = &.{},
        });

        xmltest.linkLibrary(lib);
        xmltest.linkLibCpp();

        // Install test executable
        b.installArtifact(xmltest);

        // Create test step
        const run_tests = b.addRunArtifact(xmltest);
        run_tests.setCwd(upstream.path("."));

        const test_step = b.step("test", "Run the test suite");
        test_step.dependOn(&run_tests.step);
    }

    // Documentation generation
    const docs = b.addInstallDirectory(.{
        .source_dir = upstream.path("docs"),
        .install_dir = .{ .custom = "docs" },
        .install_subdir = "",
    });

    const docs_step = b.step("docs", "Install documentation");
    docs_step.dependOn(&docs.step);
}
