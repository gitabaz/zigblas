const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const Complex = std.math.complex.Complex;

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        nrows: usize,
        ncols: usize,
        allocator: *Allocator,
        data: []T,

        pub fn init(nrows: usize, ncols: usize, allocator: *Allocator) !Self {
            return Self{
                .nrows = nrows,
                .ncols = ncols,
                .allocator = allocator,
                .data = try allocator.alloc(T, nrows * ncols),
            };
        }

        pub fn initWithArray(data: []T, nrows: usize, ncols: usize, allocator: *Allocator) !Self {
            var mat = try init(nrows, ncols, allocator);
            std.mem.copy(T, mat.data, data);
            return mat;
        }
        pub fn initWithZeroes(nrows: usize, ncols: usize, allocator: *Allocator) !Self {
            var mat = try init(nrows, ncols, allocator);
            std.mem.set(T, mat.data, std.mem.zeroes(T));
            return mat;
        }

        pub fn set(self: Self, i: usize, j: usize, val: T) void {
            self.data[i * self.ncols + j] = val;
        }
        pub fn get(self: Self, i: usize, j: usize) T {
            return self.data[i * self.ncols + j];
        }
        pub fn free(self: Self) void {
            self.allocator.free(self.data);
        }
        //pub fn print(self: Self) void {
        //    var i: usize = 0;
        //    while (i < self.nrows) : (i += 1) {
        //        var j: usize = 0;
        //        while (j < self.ncols) : (j += 1) {
        //            print("{} ", .{self.get(i, j)});
        //        }
        //        print("\n", .{});
        //    }
        //}
    };
}

pub const MatrixF64 = Matrix(f64);
pub const MatrixComplexF64 = Matrix(Complex(f64));

test "MatrixF64 init set get" {
    const allocator = std.testing.allocator;
    const nrows: usize = 2;
    const ncols: usize = 3;
    var matNxM = try MatrixF64.init(nrows, ncols, allocator);
    defer matNxM.free();
    testing.expect(matNxM.nrows == nrows);
    testing.expect(matNxM.ncols == ncols);

    var i: usize = 0;
    while (i < matNxM.nrows) : (i += 1) {
        var j: usize = 0;
        while (j < matNxM.ncols) : (j += 1) {
            matNxM.set(i, j, @intToFloat(f64, i * j));
            testing.expect(matNxM.get(i, j) == @intToFloat(f64, i * j));
        }
    }
}

test "MatrixF64 initWithArray set get" {
    const allocator = std.testing.allocator;
    const nrows: usize = 2;
    const ncols: usize = 3;
    var data_array = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
    var matNxM = try MatrixF64.initWithArray(&data_array, nrows, ncols, allocator);
    defer matNxM.free();
    testing.expect(matNxM.nrows == nrows);
    testing.expect(matNxM.ncols == ncols);

    var i: usize = 0;
    while (i < matNxM.nrows) : (i += 1) {
        var j: usize = 0;
        while (j < matNxM.ncols) : (j += 1) {
            testing.expect(matNxM.get(i, j) == 1.0 + @intToFloat(f64, i * ncols + j));
        }
    }
}

test "MatrixF64 initWithZeroes set get" {
    const allocator = std.testing.allocator;
    const nrows: usize = 2;
    const ncols: usize = 3;
    var matNxM = try MatrixF64.initWithZeroes(nrows, ncols, allocator);
    defer matNxM.free();
    testing.expect(matNxM.nrows == nrows);
    testing.expect(matNxM.ncols == ncols);

    var i: usize = 0;
    while (i < matNxM.nrows) : (i += 1) {
        var j: usize = 0;
        while (j < matNxM.ncols) : (j += 1) {
            testing.expect(matNxM.get(i, j) == 0.0);
        }
    }
}

test "MatrixF64 initWithZeroes set get" {
    const allocator = std.testing.allocator;
    const nrows: usize = 2;
    const ncols: usize = 3;
    var matNxM = try MatrixComplexF64.initWithZeroes(nrows, ncols, allocator);
    defer matNxM.free();
    testing.expect(matNxM.nrows == nrows);
    testing.expect(matNxM.ncols == ncols);

    var i: usize = 0;
    while (i < matNxM.nrows) : (i += 1) {
        var j: usize = 0;
        while (j < matNxM.ncols) : (j += 1) {
            testing.expect(matNxM.get(i, j).re == 0.0);
            testing.expect(matNxM.get(i, j).im == 0.0);
        }
    }
}
