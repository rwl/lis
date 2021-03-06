/* Copyright (C) 2005 The Scalable Software Infrastructure Project. All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
   3. Neither the name of the project nor the names of its contributors 
      may be used to endorse or promote products derived from this software 
      without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE SCALABLE SOFTWARE INFRASTRUCTURE PROJECT
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE SCALABLE SOFTWARE INFRASTRUCTURE
   PROJECT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
   OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef HAVE_CONFIG_H
        #include "lis_config.h"
#else
#ifdef HAVE_CONFIG_WIN_H
        #include "lis_config_win.h"
#endif
#endif

#include <stdio.h>
#include "lis.h"
LIS_INT main(LIS_INT argc, char* argv[])
{
    LIS_MATRIX A;
    LIS_VECTOR b,x,u;
    LIS_SOLVER solver;
    LIS_INT my_rank;
#ifdef USE_MPI
    int int_nprocs,int_my_rank;
#endif
    LIS_INT err,i,n,gn,is,ie,iter;
    n  = 12;
    lis_initialize(&argc, &argv);

#ifdef USE_MPI
    MPI_Comm_size(MPI_COMM_WORLD,&int_nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&int_my_rank);
    my_rank = int_my_rank;
#else
    my_rank = 0;
#endif

    lis_matrix_create(LIS_COMM_WORLD,&A); 
    err = lis_matrix_set_size(A,0,n);
    CHKERR(err);
    lis_matrix_get_size(A,&n,&gn);
    lis_matrix_get_range(A,&is,&ie);
    for(i=is;i<ie;i++)
    {
        if( i>0   )  lis_matrix_set_value(LIS_INS_VALUE,i,i-1,-1.0,A);
        if( i<gn-1 ) lis_matrix_set_value(LIS_INS_VALUE,i,i+1,-1.0,A);
        lis_matrix_set_value(LIS_INS_VALUE,i,i,2.0,A);
    }
    lis_matrix_set_type(A,LIS_MATRIX_CSR);
    lis_matrix_assemble(A);

    lis_vector_duplicate(A,&u);
    lis_vector_duplicate(A,&b);
    lis_vector_duplicate(A,&x);
    lis_vector_set_all(1.0,u);
    lis_matvec(A,u,b);
    lis_solver_create(&solver);
    lis_solver_set_option("-print mem",solver);
    lis_solver_set_optionC(solver);
    lis_solve(A,b,x,solver);
    lis_solver_get_iter(solver,&iter);
    if (my_rank==0)
      {
#ifdef _LONG__LONG
	printf("number of iterations = %lld\n",iter);
#else
	printf("number of iterations = %d\n",iter);
#endif
	printf("\n");
      }
    lis_vector_print(x);

    lis_matrix_destroy(A);
    lis_vector_destroy(b);
    lis_vector_destroy(x);
    lis_vector_destroy(u);
    lis_solver_destroy(solver);
    lis_finalize();
    return 0;
}
