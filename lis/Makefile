default: all

EMDIR = packages/emscripten

include $(EMDIR)/complex.inc

DEXP_NAME = -s "EXPORT_NAME='DLIS'" -s MODULARIZE=1
ZEXP_NAME = -s "EXPORT_NAME='ZLIS'" -s MODULARIZE=1

EXP_LIS = \
'_lis_initialize',\
'_lis_finalize'

EXP_VECTOR = \
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
'_lis_vector_real',\
'_lis_vector_imaginary',\
'_lis_vector_argument',\
'_lis_vector_conjugate'

EXP_MATRIX = \
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
'_lis_matrix_transpose',\
'_lis_matrix_sum_duplicates',\
'_lis_matrix_sort_indexes',\
\
'_lis_matvec',\
'_lis_matvect'

EXP_SOLVER = \
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
'_lis_solve'

EXP_ESOLVER = \
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
'_lis_esolver_get_esolver'

EXP_OUTPUT = \
'_lis_input',\
'_lis_input_matrix',\
'_lis_input_vector',\
'_lis_output',\
'_lis_output_matrix',\
'_lis_output_vector',\
'_lis_solver_output_rhistory',\
'_lis_esolver_output_rhistory'

DEXP_FUNC = -s EXPORTED_FUNCTIONS="['_malloc',\
$(EXP_LIS),\
$(EXP_VECTOR),\
$(EXP_MATRIX),\
$(EXP_SOLVER),\
$(EXP_ESOLVER),\
$(EXP_OUTPUT)]" 

ZEXP_FUNC = -s EXPORTED_FUNCTIONS="['_malloc',\
$(EXP_LIS),\
$(EXP_VECTOR),\
$(EXP_MATRIX),\
$(EXP_SOLVER),\
$(EXP_ESOLVER),\
$(EXP_OUTPUT),\
'_zlis_vector_set_value',\
'_zlis_vector_axpy',\
'_zlis_vector_xpay',\
'_zlis_vector_axpyz',\
'_zlis_vector_scale',\
'_zlis_vector_set_all',\
'_zlis_vector_shift',\
'_zlis_matrix_set_value',\
$(EXP_COMPLEX)]"

LIBDIR = lib
WEBDIR = $(LIBDIR)/web

EMPOST = $(EMDIR)/post.js
ZEXT = $(EMDIR)/complex.c
ZLIS = $(LIBDIR)/src/web/zlis.c

DEMFLAGS = $(DEXP_NAME) $(DEXP_FUNC) --post-js $(EMPOST)
ZEMFLAGS = $(ZEXP_NAME) $(ZEXP_FUNC) --post-js $(EMPOST)

DLIBS = $(WEBDIR)/dlis/lib/liblis.a
ZLIBS = $(WEBDIR)/zlis/lib/liblis.a
ZINC  = -I$(WEBDIR)/zlis/include
DDEFS = -Wall -Werror -DHAVE_CONFIG_H -D_GNU_SOURCE
ZDEFS = -Wall -Werror -DHAVE_CONFIG_H -D_GNU_SOURCE -D_COMPLEX

#all: web native

web: cleanweb $(WEBDIR)/dlis.js $(WEBDIR)/zlis.js

$(WEBDIR)/dlis.js: $(DLIBS) Makefile $(EMPOST)
	$(CC) $(CFLAGS) $(DLIBS) $(DEMFLAGS) -o $@

$(WEBDIR)/zlis.js: $(ZLIBS) Makefile $(ZEXT) $(ZLIS) $(EMPOST)
	$(CC) $(CFLAGS) $(ZLIBS) $(ZINC) $(ZDEFS) $(ZEXT) $(ZLIS) $(ZEMFLAGS) -o $@


DNATDIR = $(LIBDIR)/native/dlis
ZNATDIR = $(LIBDIR)/native/zlis
NSRCDIR = $(LIBDIR)/src/native

native: cleannative $(NSRCDIR)/libdlis_extension.so $(NSRCDIR)/libzlis_extension.so

$(NSRCDIR)/dlis_extension.o: $(NSRCDIR)/lis_extension.c
	$(CC) -fPIC -std=c99 $(DDEFS) -I/usr/lib/dart/include -I$(DNATDIR)/include -DDART_SHARED_LIB -o $@ -c $<

$(NSRCDIR)/libdlis_extension.so: $(NSRCDIR)/dlis_extension.o
	$(CC) -L$(DNATDIR)/lib $(DDEFS) -shared -Wl,-rpath=$(DNATDIR)/lib,-soname,libdlis_extension.so -o $@ $< -llis


$(NSRCDIR)/zlis_extension.o: $(NSRCDIR)/lis_extension.c
	$(CC) -fPIC -std=c99 $(ZDEFS) -I/usr/lib/dart/include -I$(ZNATDIR)/include -DDART_SHARED_LIB -o $@ -c $<

$(NSRCDIR)/libzlis_extension.so: $(NSRCDIR)/zlis_extension.o
	$(CC) -L$(ZNATDIR)/lib $(ZDEFS) -shared -Wl,-rpath=$(ZNATDIR)/lib,-soname,libzlis_extension.so -o $@ $< -llis

#$(DLIBS):
#	( cd .. ; $(MAKE) all )

clean: cleanweb cleannative

cleanweb:
	( cd $(WEBDIR) ; $(RM) *lis*.js* )

cleannative:
	@( cd $(NSRCDIR) ; $(RM) *.o )
	@( cd $(NSRCDIR) ; $(RM) *.so )
