const std = @import("std");
const testing = std.testing;
const print = std.debug.print;
const Complex = std.math.complex.Complex;

const c = @import("c.zig");
pub const matrix = @import("matrix.zig");
pub const blas1 = @import("blas1.zig");
pub const blas3 = @import("blas3.zig");

pub fn getNumThreads() c_int {
    return c.openblas_get_num_threads();
}

pub fn setNumThreads(n: c_int) void {
    return c.openblas_set_num_threads(n);
}

pub fn getNumProcs() c_int {
    return c.openblas_get_num_procs();
}

pub fn getConfig() [*:0]u8 {
    return c.openblas_get_config();
}

pub fn getCoreName() [*:0]u8 {
    return c.openblas_get_corename();
}

pub fn getParallel() c_int {
    return c.openblas_get_parallel();
}

test "zigblas" {
    _ = @import("matrix.zig");
    _ = @import("blas1.zig");
    _ = @import("blas3.zig");
}
