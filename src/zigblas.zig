const std = @import("std");
const testing = std.testing;
const print = std.debug.print;
const Complex = std.math.complex.Complex;

const c = @cImport({
    @cInclude("cblas.h");
});

pub const matrix = @import("matrix.zig");

pub const BlasInt = c.blasint;
pub const Transpose = c.enum_CBLAS_TRANSPOSE;
pub const Layout = c.enum_CBLAS_ORDER;

//C := alpha*op(A)*op(B) + beta*C
pub fn gemm(comptime T: type, order: Layout, transA: Transpose, transB: Transpose, alpha: T, A: *matrix.Matrix(T), B: *matrix.Matrix(T), beta: T, C: *matrix.Matrix(T)) void {
    var num_rows_opA: BlasInt = undefined;
    var num_cols_opA: BlasInt = undefined;
    var num_rows_opB: BlasInt = undefined;
    var num_cols_opB: BlasInt = undefined;
    if (transA == Transpose.CblasNoTrans) {
        num_rows_opA = @intCast(BlasInt, A.nrows);
        num_cols_opA = @intCast(BlasInt, A.ncols);
    } else {
        num_rows_opA = @intCast(BlasInt, A.ncols);
        num_cols_opA = @intCast(BlasInt, A.nrows);
    }

    if (transB == Transpose.CblasNoTrans) {
        num_rows_opB = @intCast(BlasInt, B.nrows);
        num_cols_opB = @intCast(BlasInt, B.ncols);
    } else {
        num_rows_opB = @intCast(BlasInt, B.ncols);
        num_cols_opB = @intCast(BlasInt, B.nrows);
    }

    var lda: BlasInt = undefined;
    var ldb: BlasInt = undefined;
    var ldc: BlasInt = undefined;
    if (order == Layout.CblasRowMajor) {
        lda = @intCast(BlasInt, A.ncols);
        ldb = @intCast(BlasInt, B.ncols);
        ldc = @intCast(BlasInt, C.ncols);
    } else {
        lda = @intCast(BlasInt, A.nrows);
        ldb = @intCast(BlasInt, B.nrows);
        ldc = @intCast(BlasInt, C.nrows);
    }

    if (T == f32) {
        c.cblas_sgemm(order, transA, transB, num_rows_opA, num_cols_opB, num_cols_opA, alpha, A.data.ptr, lda, B.data.ptr, ldb, beta, C.data.ptr, ldc);
    } else if (T == f64) {
        c.cblas_dgemm(order, transA, transB, num_rows_opA, num_cols_opB, num_cols_opA, alpha, A.data.ptr, lda, B.data.ptr, ldb, beta, C.data.ptr, ldc);
    } else if (T == Complex(f32)) {
        c.cblas_cgemm(order, transA, transB, num_rows_opA, num_cols_opB, num_cols_opA, &.{ alpha.re, alpha.im }, A.data.ptr, lda, B.data.ptr, ldb, &.{ beta.re, beta.im }, C.data.ptr, ldc);
    } else if (T == Complex(f64)) {
        c.cblas_zgemm(order, transA, transB, num_rows_opA, num_cols_opB, num_cols_opA, &.{ alpha.re, alpha.im }, A.data.ptr, lda, B.data.ptr, ldb, &.{ beta.re, beta.im }, C.data.ptr, ldc);
    }
}

test "sdgemm" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_AB = [_]T{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
        var matA = try matrix.Matrix(T).initWithArray(&data_array_AB, 3, 2, allocator);
        defer matA.free();
        var matB = try matrix.Matrix(T).initWithArray(&data_array_AB, 3, 2, allocator);
        defer matB.free();

        var data_array_C = [_]T{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0 };
        var matC = try matrix.Matrix(T).initWithArray(&data_array_C, 3, 3, allocator);
        defer matC.free();

        var data_array_R = [_]T{ 9.5, 20.5, 31.5, 24.5, 47.5, 70.5, 39.5, 74.5, 109.5 };
        var matR = try matrix.Matrix(T).initWithArray(&data_array_R, 3, 3, allocator);
        defer matR.free();

        const alpha = 1.5;
        const beta = 2.0;
        gemm(T, Layout.CblasRowMajor, Transpose.CblasNoTrans, Transpose.CblasTrans, alpha, &matA, &matB, beta, &matC);

        var i: usize = 0;
        while (i < matC.nrows) : (i += 1) {
            var j: usize = 0;
            while (j < matC.ncols) : (j += 1) {
                testing.expect(matC.get(i, j) == matR.get(i, j));
            }
        }
    }
}

test "czgemm" {
    const allocator = std.testing.allocator;
    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_AB = [_]T{ T.new(1.0, 6.0), T.new(2.0, 5.0), T.new(3.0, 4.0), T.new(4.0, 3.0), T.new(5.0, 2.0), T.new(6.0, 1.0) };
        var matA = try matrix.Matrix(T).initWithArray(&data_array_AB, 3, 2, allocator);
        defer matA.free();
        var matB = try matrix.Matrix(T).initWithArray(&data_array_AB, 3, 2, allocator);
        defer matB.free();

        var data_array_C = [_]T{ T.new(1.0, 0.0), T.new(2.0, 0.0), T.new(3.0, 0.0), T.new(4.0, 0.0), T.new(5.0, 0.0), T.new(6.0, 0.0), T.new(7.0, 0.0), T.new(8.0, 0.0), T.new(9.0, 0.0) };
        var matC = try matrix.Matrix(T).initWithArray(&data_array_C, 3, 3, allocator);
        defer matC.free();

        var data_array_R = [_]T{ T.new(101.0, 133.5), T.new(23.0, 145.0), T.new(-55.0, 156.5), T.new(139.0, 64.0), T.new(85.0, 107.5), T.new(31.0, 151.0), T.new(177.0, -5.5), T.new(147.0, 70.0), T.new(117.0, 145.5) };
        var matR = try matrix.Matrix(T).initWithArray(&data_array_R, 3, 3, allocator);
        defer matR.free();

        const alpha = T.new(1.5, 2.0);
        const beta = T.new(2.0, 1.5);
        gemm(T, Layout.CblasRowMajor, Transpose.CblasNoTrans, Transpose.CblasConjTrans, alpha, &matA, &matB, beta, &matC);

        var i: usize = 0;
        while (i < matC.nrows) : (i += 1) {
            var j: usize = 0;
            while (j < matC.ncols) : (j += 1) {
                testing.expect(matC.get(i, j).re == matR.get(i, j).re);
                testing.expect(matC.get(i, j).im == matR.get(i, j).im);
            }
        }
    }
}

test "zigblas" {
    _ = @import("matrix.zig");
}
