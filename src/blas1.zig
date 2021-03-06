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

pub fn axpy(comptime T: type, a: T, x: *matrix.Matrix(T), y: *matrix.Matrix(T)) void {
    const n = @intCast(BlasInt, x.nrows);
    if (T == f32) {
        c.cblas_saxpy(n, a, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == f64) {
        c.cblas_daxpy(n, a, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == Complex(f32)) {
        c.cblas_caxpy(n, &.{ a.re, a.im }, x.data.ptr, 1, y.data.ptr, 1);
    } else if (T == Complex(f64)) {
        c.cblas_zaxpy(n, &.{ a.re, a.im }, x.data.ptr, 1, y.data.ptr, 1);
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
