// zig run examples/ex_gemm.zig --library c --main-pkg-path ../
const std = @import("std");
const zigblas = @import("zigblas");
const print = std.debug.print;

const MatrixF64 = zigblas.matrix.Matrix(f64);

pub fn main() !void {
    const allocator = std.heap.c_allocator;
    var data_array_AB = [_]f64{ 1.0, 2.0, 3.0, 4.0 };
    var matA = try MatrixF64.initWithArray(&data_array_AB, 2, 2, allocator);
    defer matA.free();
    var matB = try MatrixF64.initWithArray(&data_array_AB, 2, 2, allocator);
    defer matB.free();
    var matC = try MatrixF64.initWithZeroes(2, 2, allocator);
    defer matC.free();

    zigblas.setNumThreads(4);
    print("Num threads: {}\n", .{zigblas.getNumThreads()});
    print("Num procs: {}\n", .{zigblas.getNumProcs()});
    print("Config: {}\n", .{zigblas.getConfig()});
    print("Core Name: {}\n", .{zigblas.getCoreName()});
    print("Parallel: {}\n", .{zigblas.getParallel()});

    print("Matrix A:\n", .{});
    printMatrix(matA);
    print("Matrix B:\n", .{});
    printMatrix(matB);

    const alpha = 1.0;
    const beta = 0.0;

    zigblas.gemm(f64, zigblas.Layout.CblasRowMajor, zigblas.Transpose.CblasNoTrans, zigblas.Transpose.CblasNoTrans, alpha, &matA, &matB, beta, &matC);
    print("Matrix C = A * B: \n", .{});
    printMatrix(matC);
}

fn printMatrix(mat: MatrixF64) void {
    var i: usize = 0;
    while (i < mat.nrows) : (i += 1) {
        var j: usize = 0;
        while (j < mat.ncols) : (j += 1) {
            print("{d:.2} ", .{mat.get(i, j)});
        }
        print("\n", .{});
    }
}
