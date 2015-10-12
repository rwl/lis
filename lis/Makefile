default: all

DEXP_NAME = -s "EXPORT_NAME='DLIS'"
ZEXP_NAME = -s "EXPORT_NAME='ZLIS'"

EXP_FUNC = -s EXPORTED_FUNCTIONS="['_malloc',\
'_lis_initialize',\
\
'_lis_vector_create',\
'_lis_vector_set_size',\
'_lis_vector_destroy',\
'_lis_vector_duplicate',\
'_lis_vector_get_size',\
'_lis_vector_get_range',\
'_lis_vector_get_value',\
'_lis_vector_get_values',\
'_lis_vector_set_value',\
'_lis_vector_set_values',\
'_lis_vector_set_values2',\
'_lis_vector_print',\
'_lis_vector_scatter',\
'_lis_vector_gather',\
'_lis_vector_is_null',\
'_lis_vector_swap',\
'_lis_vector_copy',\
'_lis_vector_axpy',\
'_lis_vector_xpay',\
'_lis_vector_axpyz',\
'_lis_vector_scale',\
'_lis_vector_pmul',\
'_lis_vector_pdiv',\
'_lis_vector_set_all',\
'_lis_vector_abs',\
'_lis_vector_reciprocal',\
'_lis_vector_shift',\
'_lis_vector_dot',\
'_lis_vector_nrm1',\
'_lis_vector_nrm2',\
'_lis_vector_nrmi',\
'_lis_vector_sum',\
\
'_lis_matrix_create',\
'_lis_matrix_destroy',\
'_lis_matrix_assemble',\
'_lis_matrix_is_assembled',\
'_lis_matrix_duplicate',\
'_lis_matrix_set_size',\
'_lis_matrix_get_size',\
'_lis_matrix_get_range',\
'_lis_matrix_get_nnz',\
'_lis_matrix_set_type',\
'_lis_matrix_get_type',\
'_lis_matrix_set_value',\
'_lis_matrix_set_values',\
'_lis_matrix_malloc',\
'_lis_matrix_get_diagonal',\
'_lis_matrix_scale',\
'_lis_matrix_convert',\
'_lis_matrix_copy',\
'_lis_matrix_set_blocksize',\
'_lis_matrix_unset',\
\
'_lis_matrix_malloc_csr',\
'_lis_matrix_set_csr',\
'_lis_matrix_malloc_csc',\
'_lis_matrix_set_csc',\
\
'_lis_matrix_set_dia',\
'_lis_matrix_malloc_dia',\
\
'_lis_matrix_malloc_coo',\
'_lis_matrix_set_coo',\
'_lis_matrix_set_dns',\
'_lis_matrix_malloc_dns',\
\
'_lis_solver_create',\
'_lis_solver_destroy',\
'_lis_solver_get_iter',\
'_lis_solver_get_iterex',\
'_lis_solver_get_time',\
'_lis_solver_get_timeex',\
'_lis_solver_get_residualnorm',\
'_lis_solver_get_solver',\
'_lis_solver_get_precon',\
'_lis_solver_get_status',\
'_lis_solver_get_rhistory',\
'_lis_solver_set_option',\
'_lis_solver_set_optionC',\
'_lis_solve',\
\
'_lis_esolver_create',\
'_lis_esolver_destroy',\
'_lis_esolver_set_option',\
'_lis_esolver_set_optionC',\
'_lis_esolve',\
'_lis_esolver_get_iter',\
'_lis_esolver_get_iterex',\
'_lis_esolver_get_time',\
'_lis_esolver_get_timeex',\
'_lis_esolver_get_residualnorm',\
'_lis_esolver_get_status',\
'_lis_esolver_get_rhistory',\
'_lis_esolver_get_evalues',\
'_lis_esolver_get_evectors',\
'_lis_esolver_get_residualnorms',\
'_lis_esolver_get_iters',\
'_lis_esolver_get_esolver',\
\
'_lis_input',\
'_lis_input_matrix',\
'_lis_input_vector',\
'_lis_output',\
'_lis_output_matrix',\
'_lis_output_vector',\
'_lis_solver_output_rhistory',\
'_lis_esolver_output_rhistory',\
\
'_lis_finalize']" 

LIBDIR = lib
SRCDIR = $(LIBDIR)/src
EMDIR = packages/emscripten

EMFLAGS = $(DEXP_NAME) $(EXP_FUNC) --pre-js $(SRCDIR)/dpre.js \
--post-js $(EMDIR)/post.js

ZEMFLAGS = $(ZEXP_NAME) $(EXP_FUNC) --pre-js $(SRCDIR)/zpre.js \
--post-js $(EMDIR)/post.js

DLIBS = $(LIBDIR)/dlis/lib/liblis.a
ZLIBS = $(LIBDIR)/zlis/lib/liblis.a

all: module

module: $(LIBDIR)/dlis.js $(LIBDIR)/zlis.js

$(LIBDIR)/dlis.js: $(DLIBS) Makefile $(SRCDIR)/dpre.js $(EMDIR)/post.js
	$(CC) $(CFLAGS) $(DLIBS) $(EMFLAGS) -o $@

$(LIBDIR)/zlis.js: $(ZLIBS) Makefile $(SRCDIR)/zpre.js $(EMDIR)/post.js
	$(CC) $(CFLAGS) $(ZLIBS) $(ZEMFLAGS) -o $@

$(LISLIB):
	( cd .. ; $(MAKE) all )

clean:
	( cd lib ; $(RM) *lis*.js* )
