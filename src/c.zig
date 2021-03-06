pub usingnamespace @cImport({
    @cInclude("cblas.h");
});

pub const BlasInt = blasint;
pub const Transpose = enum_CBLAS_TRANSPOSE;
pub const Layout = enum_CBLAS_ORDER;
pub const UpLo = enum_CBLAS_UPLO;
pub const Diag = enum_CBLAS_DIAG;
pub const Side = enum_CBLAS_SIDE;
