const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const openblas_include_dir = "/home/olabian/opt/openblas/include";
    const openblas_lib_dir = "/home/olabian/opt/openblas/lib";

    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("zigblas", "src/zigblas.zig");
    lib.setBuildMode(mode);
    lib.install();

    var tests = b.addTest("src/zigblas.zig");
    tests.setBuildMode(mode);
    tests.addIncludeDir(openblas_include_dir);
    tests.addLibPath(openblas_lib_dir);
    tests.linkLibC();
    tests.linkSystemLibrary("openblas");

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.step);

    // Examples
    const target = b.standardTargetOptions(.{});

    const ex_gemm_exe = b.addExecutable("ex_gemm", "examples/ex_gemm.zig");
    ex_gemm_exe.setTarget(target);
    ex_gemm_exe.setBuildMode(mode);
    ex_gemm_exe.addIncludeDir(openblas_include_dir);
    ex_gemm_exe.addLibPath(openblas_lib_dir);
    ex_gemm_exe.linkLibC();
    ex_gemm_exe.linkSystemLibrary("openblas");

    ex_gemm_exe.addPackage(.{
        .name = "zigblas",
        .path = "src/zigblas.zig",
    });

    ex_gemm_exe.install();

    const ex_gemm_run_cmd = ex_gemm_exe.run();
    ex_gemm_run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("examples", "Run the app");
    run_step.dependOn(&ex_gemm_run_cmd.step);
}
