const std = @import("std");
const print = std.debug.print;
const Complex = std.math.complex.Complex;

const c = @import("c.zig");
const BlasInt = c.BlasInt;
const Transpose = c.Transpose;
const Layout = c.Layout;
const UpLo = c.UpLo;
const Diag = c.Diag;
const Side = c.Side;

pub const matrix = @import("matrix.zig");

pub fn dot(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt, y: *matrix.Matrix(T), incy: BlasInt) T {
    if (T == f32) {
        return c.cblas_sdot(n, x.data.ptr, incx, y.data.ptr, incy);
    } else if (T == f64) {
        return c.cblas_ddot(n, x.data.ptr, incx, y.data.ptr, incy);
    }
}

pub fn dotu(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt, y: *matrix.Matrix(T), incy: BlasInt, u: *T) void {
    if (T == Complex(f32)) {
        return c.cblas_cdotu_sub(n, x.data.ptr, incx, y.data.ptr, incy, u);
    } else if (T == Complex(f64)) {
        return c.cblas_zdotu_sub(n, x.data.ptr, incx, y.data.ptr, incy, u);
    }
}

pub fn dotc(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt, y: *matrix.Matrix(T), incy: BlasInt, u: *T) void {
    if (T == Complex(f32)) {
        return c.cblas_cdotc_sub(n, x.data.ptr, incx, y.data.ptr, incy, u);
    } else if (T == Complex(f64)) {
        return c.cblas_zdotc_sub(n, x.data.ptr, incx, y.data.ptr, incy, u);
    }
}

pub fn copy(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt, y: *matrix.Matrix(T), incy: BlasInt) void {
    if (T == f32) {
        c.cblas_scopy(n, x.data.ptr, incx, y.data.ptr, incy);
    } else if (T == f64) {
        c.cblas_dcopy(n, x.data.ptr, incx, y.data.ptr, incy);
    } else if (T == Complex(f32)) {
        c.cblas_ccopy(n, x.data.ptr, incx, y.data.ptr, incy);
    } else if (T == Complex(f64)) {
        c.cblas_zcopy(n, x.data.ptr, incx, y.data.ptr, incy);
    }
}

pub fn nrm2(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt) T {
    if (T == f32) {
        return c.cblas_snrm2(n, x.data.ptr, incx);
    } else if (T == f64) {
        return c.cblas_dnrm2(n, x.data.ptr, incx);
    } else if (T == Complex(f32)) {
        return T.new(c.cblas_scnrm2(n, x.data.ptr, incx), 0.0);
    } else if (T == Complex(f64)) {
        return T.new(c.cblas_dznrm2(n, x.data.ptr, incx), 0.0);
    }
}

pub fn axpy(comptime T: type, a: T, x: *matrix.Matrix(T), y: *matrix.Matrix(T)) void {
    const n = @intCast(BlasInt, x.nrows);
    if (T == f32) {
        c.cblas_saxpy(n, a, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == f64) {
        c.cblas_daxpy(n, a, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == Complex(f32)) {
        c.cblas_caxpy(n, &a, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == Complex(f64)) {
        c.cblas_zaxpy(n, &a, x.data.ptr, 1, y.data.ptr, 1);
    }
}

pub fn asum(comptime T: type, n: BlasInt, x: *matrix.Matrix(T), incx: BlasInt) T {
    if (T == f32) {
        return c.cblas_sasum(n, x.data.ptr, incx);
    } else if (T == f64) {
        return c.cblas_dasum(n, x.data.ptr, incx);
    } else if (T == Complex(f32)) {
        return T.new(c.cblas_scasum(n, x.data.ptr, incx), 0.0);
    } else if (T == Complex(f64)) {
        return T.new(c.cblas_dzasum(n, x.data.ptr, incx), 0.0);
    }
}

test "sdaxpy" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_AB = [_]T{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecX.free();
        var vecY = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecY.free();

        const a = 2.0;
        axpy(T, a, &vecX, &vecY);

        var data_array_R = [_]T{ 3.0, 6.0, 9.0, 12.0, 15.0, 18.0 };
        var vecR = try matrix.Matrix(T).initWithArray(&data_array_R, 6, 1, allocator);
        defer vecR.free();

        var i: usize = 0;
        while (i < vecY.nrows) : (i += 1) {
            std.testing.expect(vecY.get1(i) == vecR.get1(i));
        }
    }
}

test "czaxpy" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_AB = [_]T{ T.new(1.0, 1.0), T.new(2.0, 2.0), T.new(3.0, 3.0), T.new(4.0, 4.0), T.new(5.0, 5.0), T.new(6.0, 6.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecX.free();
        var vecY = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecY.free();

        const a = T.new(2.0, 2.0);
        axpy(T, a, &vecX, &vecY);

        var data_array_R = [_]T{ T.new(1.0, 5.0), T.new(2.0, 10.0), T.new(3.0, 15.0), T.new(4.0, 20.0), T.new(5.0, 25.0), T.new(6.0, 30.0) };
        var vecR = try matrix.Matrix(T).initWithArray(&data_array_R, 6, 1, allocator);
        defer vecR.free();

        var i: usize = 0;
        while (i < vecY.nrows) : (i += 1) {
            std.testing.expect(vecY.get1(i).re == vecR.get1(i).re);
            std.testing.expect(vecY.get1(i).im == vecR.get1(i).im);
        }
    }
}

test "sdasum" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_AB = [_]T{ 1.0, -2.0, 3.0, -4.0, 5.0, 6.0 };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecX.free();

        const sum = asum(T, @intCast(BlasInt, vecX.nrows), &vecX, 1);

        std.testing.expect(sum == 21.0);
    }
}

test "scdzasum" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_AB = [_]T{ T.new(1.0, 1.0), T.new(-2.0, -2.0), T.new(3.0, 3.0), T.new(-4.0, -4.0), T.new(5.0, 5.0), T.new(6.0, 6.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_AB, 6, 1, allocator);
        defer vecX.free();

        const sum = asum(T, @intCast(BlasInt, vecX.nrows), &vecX, 1);

        std.testing.expect(sum.re == 42.0);
    }
}

test "sddot" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_X = [_]T{ 1.0, 1.0, 1.0 };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();
        var data_array_Y = [_]T{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 };
        var vecY = try matrix.Matrix(T).initWithArray(&data_array_Y, 6, 1, allocator);
        defer vecY.free();

        const dp = dot(T, @intCast(BlasInt, vecX.nrows), &vecX, 1, &vecY, 2);
        std.testing.expect(dp == 3.0);
    }
}

test "czdotu" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_X = [_]T{ T.new(0.0, 1.0), T.new(0.0, 1.0), T.new(0.0, 1.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();
        var data_array_Y = [_]T{ T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0) };
        var vecY = try matrix.Matrix(T).initWithArray(&data_array_Y, 6, 1, allocator);
        defer vecY.free();

        var res: T = undefined;
        dotu(T, @intCast(BlasInt, vecX.nrows), &vecX, 1, &vecY, 2, &res);
        std.testing.expect(res.re == -3.0);
        std.testing.expect(res.im == 3.0);
    }
}

test "czdotc" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_X = [_]T{ T.new(0.0, 1.0), T.new(0.0, 1.0), T.new(0.0, 1.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();
        var data_array_Y = [_]T{ T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0), T.new(1.0, 1.0) };
        var vecY = try matrix.Matrix(T).initWithArray(&data_array_Y, 6, 1, allocator);
        defer vecY.free();

        var res: T = undefined;
        dotc(T, @intCast(BlasInt, vecX.nrows), &vecX, 1, &vecY, 2, &res);
        std.testing.expect(res.re == 3.0);
        std.testing.expect(res.im == -3.0);
    }
}

test "sdcopy" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_X = [_]T{ 1.0, 2.0, 3.0 };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();
        var vecY = try matrix.Matrix(T).initWithZeroes(3, 1, allocator);
        defer vecY.free();

        copy(T, @intCast(BlasInt, vecX.nrows), &vecX, 1, &vecY, 1);

        var i: usize = 0;
        while (i < vecX.nrows) : (i += 1) {
            std.testing.expect(vecY.get1(i) == vecX.get1(i));
        }
    }
}

test "czcopy" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_X = [_]T{ T.new(1.0, 1.0), T.new(2.0, 2.0), T.new(3.0, 3.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();
        var vecY = try matrix.Matrix(T).initWithZeroes(3, 1, allocator);
        defer vecY.free();

        copy(T, @intCast(BlasInt, vecX.nrows), &vecX, 1, &vecY, 1);

        var i: usize = 0;
        while (i < vecX.nrows) : (i += 1) {
            std.testing.expect(vecY.get1(i).re == vecX.get1(i).re);
            std.testing.expect(vecY.get1(i).im == vecX.get1(i).im);
        }
    }
}

test "sdnrm2" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ f32, f64 }) |T| {
        var data_array_X = [_]T{ 1.0, 2.0, 3.0 };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();

        const norm = nrm2(T, @intCast(BlasInt, vecX.nrows), &vecX, 1);
        std.testing.expect(norm == std.math.sqrt(14.0));
    }
}

test "cznrm2" {
    const allocator = std.testing.allocator;

    inline for ([_]type{ Complex(f32), Complex(f64) }) |T| {
        var data_array_X = [_]T{ T.new(1.0, 1.0), T.new(2.0, 2.0), T.new(3.0, 3.0) };
        var vecX = try matrix.Matrix(T).initWithArray(&data_array_X, 3, 1, allocator);
        defer vecX.free();

        const norm = nrm2(T, @intCast(BlasInt, vecX.nrows), &vecX, 1);
        std.testing.expect(norm.re == 2.0 * std.math.sqrt(7.0));
        std.testing.expect(norm.im == 0.0);
    }
}
