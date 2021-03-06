https://github.com/xianyi/OpenBLAS/blob/develop/cblas.h
/*Set the number of threads on runtime.*/
~~openblas_set_num_threads~~
~~goto_set_num_threads~~

/*Get the number of threads on runtime.*/
~~openblas_get_num_threads~~

/*Get the number of physical processors (cores).*/
~~openblas_get_num_procs~~

/*Get the build configure on runtime.*/
~~openblas_get_config~~

/*Get the CPU corename on runtime.*/
~~openblas_get_corename~~

ifdef OPENBLAS_OS_LINUX
/* Sets thread affinity for OpenBLAS threads. `thread_idx` is in [0, openblas_get_num_threads()-1]. */
openblas_setaffinity
endif

/* Get the parallelization type which is used by OpenBLAS */
~~openblas_get_parallel~~
/* OpenBLAS is compiled for sequential use  */
define OPENBLAS_SEQUENTIAL  0
/* OpenBLAS is compiled using normal threading model */
define OPENBLAS_THREAD  1
/* OpenBLAS is compiled using OpenMP threading model */
define OPENBLAS_OPENMP 2


define CBLAS_INDEX size_t

~~CBLAS_ORDER~~
~~CBLAS_TRANSPOSE~~
~~CBLAS_LAYOUT~~
~~CBLAS_UPLO~~
~~CBLAS_DIAG~~
~~CBLAS_SIDE~~
	
~~cblas_sdsdot~~
~~cblas_dsdot~~
~~cblas_sdot~~
~~cblas_ddot~~

~~cblas_cdotu~~
~~cblas_cdotc~~
~~cblas_zdotu~~
~~cblas_zdotc~~

cblas_cdotu_sub
cblas_cdotc_sub
cblas_zdotu_sub
cblas_zdotc_sub

~~cblas_sasum~~
~~cblas_dasum~~
~~cblas_scasum~~
~~cblas_dzasum~~

cblas_ssum
cblas_dsum
cblas_scsum
cblas_dzsum

~~cblas_snrm2~~
~~cblas_dnrm2~~
~~cblas_scnrm2~~
~~cblas_dznrm2~~

CBLAS_INDEX cblas_isamax
CBLAS_INDEX cblas_idamax
CBLAS_INDEX cblas_icamax
CBLAS_INDEX cblas_izamax

CBLAS_INDEX cblas_isamin
CBLAS_INDEX cblas_idamin
CBLAS_INDEX cblas_icamin
CBLAS_INDEX cblas_izamin

CBLAS_INDEX cblas_ismax
CBLAS_INDEX cblas_idmax
CBLAS_INDEX cblas_icmax
CBLAS_INDEX cblas_izmax

CBLAS_INDEX cblas_ismin
CBLAS_INDEX cblas_idmin
CBLAS_INDEX cblas_icmin
CBLAS_INDEX cblas_izmin

~~cblas_saxpy~~
~~cblas_daxpy~~
~~cblas_caxpy~~
~~cblas_zaxpy~~

cblas_scopy
cblas_dcopy
cblas_ccopy
cblas_zcopy

cblas_sswap
cblas_dswap
cblas_cswap
cblas_zswap

cblas_srot
cblas_drot
cblas_csrot
cblas_zdrot

cblas_srotg
cblas_drotg
cblas_crotg
cblas_zrotg


cblas_srotm
cblas_drotm

cblas_srotmg
cblas_drotmg

cblas_sscal
cblas_dscal
cblas_cscal
cblas_zscal
cblas_csscal
cblas_zdscal

cblas_sgemv
cblas_dgemv
cblas_cgemv
cblas_zgemv

cblas_sger 
cblas_dger 
cblas_cgeru
cblas_cgerc
cblas_zgeru
cblas_zgerc

cblas_strsv
cblas_dtrsv
cblas_ctrsv
cblas_ztrsv

cblas_strmv
cblas_dtrmv
cblas_ctrmv
cblas_ztrmv

cblas_ssyr
cblas_dsyr
cblas_cher
cblas_zher

cblas_ssyr2
cblas_dsyr2
cblas_cher2
cblas_zher2

cblas_sgbmv
cblas_dgbmv
cblas_cgbmv
cblas_zgbmv
           

cblas_ssbmv
cblas_dsbmv


cblas_stbmv
cblas_dtbmv
cblas_ctbmv
cblas_ztbmv

cblas_stbsv
cblas_dtbsv
cblas_ctbsv
cblas_ztbsv

cblas_stpmv
cblas_dtpmv
cblas_ctpmv
cblas_ztpmv
           

cblas_stpsv
cblas_dtpsv
cblas_ctpsv
cblas_ztpsv

cblas_ssymv
cblas_dsymv
cblas_chemv
cblas_zhemv

cblas_sspmv
cblas_dspmv

cblas_sspr
cblas_dspr

cblas_chpr
cblas_zhpr

cblas_sspr2
cblas_dspr2
cblas_chpr2
cblas_zhpr2

cblas_chbmv
cblas_zhbmv

cblas_chpmv
cblas_zhpmv

~~cblas_sgemm~~
~~cblas_dgemm~~
~~cblas_cgemm~~
~~cblas_zgemm~~
cblas_cgemm3m
cblas_zgemm3m


cblas_ssymm
cblas_dsymm
cblas_csymm
cblas_zsymm

cblas_ssyrk
cblas_dsyrk
cblas_csyrk
cblas_zsyrk

cblas_ssyr2k
cblas_dsyr2k
cblas_csyr2k
cblas_zsyr2k

cblas_strmm
cblas_dtrmm
cblas_ctrmm
cblas_ztrmm

cblas_strsm
cblas_dtrsm
cblas_ctrsm
cblas_ztrsm

cblas_chemm
cblas_zhemm

cblas_cherk
cblas_zherk

cblas_cher2k
cblas_zher2k

cblas_xerbla

/*** BLAS extensions ***/

cblas_saxpby
cblas_daxpby
cblas_caxpby
cblas_zaxpby

cblas_somatcopy
cblas_domatcopy
cblas_comatcopy
cblas_zomatcopy

cblas_simatcopy
cblas_dimatcopy
cblas_cimatcopy
cblas_zimatcopy

cblas_sgeadd
cblas_dgeadd
cblas_cgeadd
cblas_zgeadd
