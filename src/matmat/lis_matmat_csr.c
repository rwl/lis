/* Copyright (C) 2005 The Scalable Software Infrastructure Project.
   All rights reserved.

   Copyright (c) 2001, 2002 Enthought, Inc.
   All rights reserved.

   Copyright (c) 2003-2012 SciPy Developers.
   All rights reserved.

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
#include <stdlib.h>
#ifdef HAVE_MALLOC_H
        #include <malloc.h>
#endif
#include <string.h>
#include <math.h>
#ifdef USE_SSE2
	#include <emmintrin.h>
#endif
#ifdef _OPENMP
	#include <omp.h>
#endif
#ifdef USE_MPI
	#include <mpi.h>
#endif
#include "lislib.h"


/*
 * Pass 1 computes CSR row pointer for the matrix product C = A * B
 *
 */
LIS_INT lis_csr_matmat_pass1(const LIS_INT n_row,
		const LIS_INT n_col,
		const LIS_INT Ap[],
		const LIS_INT Aj[],
		const LIS_INT Bp[],
		const LIS_INT Bj[],
		LIS_INT Cp[])
{
	LIS_INT i, nnz, row_nnz, jj, j, kk, k, next_nnz;

	// method that uses O(n) temp storage
	LIS_INT mask[n_col];
	for (i = 0; i < n_col; i++)
	{
		mask[i] = -1;
	}
	Cp[0] = 0;

	nnz = 0;
	for (i = 0; i < n_row; i++)
	{
		row_nnz = 0;

		for (jj = Ap[i]; jj < Ap[i+1]; jj++)
		{
			j = Aj[jj];
			for (kk = Bp[j]; kk < Bp[j+1]; kk++)
			{
				k = Bj[kk];
				if (mask[k] != i)
				{
					mask[k] = i;
					row_nnz++;
				}
			}
		}

		next_nnz = nnz + row_nnz;

		if (/*row_nnz > INT_MAX - nnz ||*/ next_nnz != (LIS_INT)next_nnz)
		{
			// Index overflowed. Note that row_nnz <= n_col and cannot overflow
			return LIS_OUT_OF_MEMORY;
		}

		nnz = next_nnz;
		Cp[i+1] = nnz;
	}
	return LIS_SUCCESS;
}


/*
 * Pass 2 computes CSR entries for matrix C = A*B using the
 * row pointer Cp[] computed in Pass 1.
 *
 */
void lis_csr_matmat_pass2(const LIS_INT n_row,
		const LIS_INT n_col,
		const LIS_INT Ap[],
		const LIS_INT Aj[],
		const LIS_SCALAR Ax[],
		const LIS_INT Bp[],
		const LIS_INT Bj[],
		const LIS_SCALAR Bx[],
		LIS_INT Cp[],
		LIS_INT Cj[],
		LIS_SCALAR Cx[])
{
	LIS_INT nnz, i, head, length, temp;
	LIS_INT jj_start, jj_end, jj, j, kk_start, kk_end, kk, k;
	LIS_SCALAR v;

	LIS_INT next[n_col];
	LIS_INT sums[n_col];
	for (i = 0; i < n_col; i++) {
		next[i] = -1;
		sums[i] = 0;
	}

	nnz = 0;

	Cp[0] = 0;

	for(i = 0; i < n_row; i++)
	{
		head   = -2;
		length =  0;

		jj_start = Ap[i];
		jj_end   = Ap[i+1];
		for(jj = jj_start; jj < jj_end; jj++)
		{
			j = Aj[jj];
			v = Ax[jj];

			kk_start = Bp[j];
			kk_end   = Bp[j+1];
			for(kk = kk_start; kk < kk_end; kk++)
			{
				k = Bj[kk];

				sums[k] += v*Bx[kk];

				if(next[k] == -1){
					next[k] = head;
					head  = k;
					length++;
				}
			}
		}

		for(jj = 0; jj < length; jj++)
		{

			if(sums[head] != 0)
			{
				Cj[nnz] = head;
				Cx[nnz] = sums[head];
				nnz++;
			}

			temp = head;
			head = next[head];

			next[temp] = -1; //clear arrays
			sums[temp] =  0;
		}

		Cp[i+1] = nnz;
	}
}


/*
 * Compute C = A*B for CSR matrices A,B
 *
 *
 * Input Arguments:
 *   I  n_row       - number of rows in A
 *   I  n_col       - number of columns in B (hence C is n_row by n_col)
 *   I  Ap[n_row+1] - row pointer
 *   I  Aj[nnz(A)]  - column indices
 *   T  Ax[nnz(A)]  - nonzeros
 *   I  Bp[?]       - row pointer
 *   I  Bj[nnz(B)]  - column indices
 *   T  Bx[nnz(B)]  - nonzeros
 * Output Arguments:
 *   I  Cp[n_row+1] - row pointer
 *   I  Cj[nnz(C)]  - column indices
 *   T  Cx[nnz(C)]  - nonzeros
 *
 * Note:
 *   Output arrays Cp, Cj, and Cx must be preallocated
 *   The value of nnz(C) will be stored in Ap[n_row] after the first pass.
 *
 * Note:
 *   Input:  A and B column indices *are not* assumed to be in sorted order
 *   Output: C column indices *are not* assumed to be in sorted order
 *           Cx will not contain any zero entries
 *
 *   Complexity: O(n_row*K^2 + max(n_row,n_col))
 *                 where K is the maximum nnz in a row of A
 *                 and column of B.
 *
 *
 *  This is an implementation of the SMMP algorithm:
 *
 *    "Sparse Matrix Multiplication Package (SMMP)"
 *      Randolph E. Bank and Craig C. Douglas
 *
 *    http://citeseer.ist.psu.edu/445062.html
 *    http://www.mgnet.org/~douglas/ccd-codes.html
 *
 */
#undef __FUNC__
#define __FUNC__ "lis_matmat_csr"
LIS_INT lis_matmat_csr(LIS_MATRIX A, LIS_MATRIX B, LIS_MATRIX C)
{
	LIS_INT err, n, *ptr, *index, nnz;
	LIS_SCALAR *value;

	LIS_DEBUG_FUNC_IN;

	if( B->matrix_type != A->matrix_type )
	{
		return LIS_ERR_ILL_ARG;
	}
	if( A->n != B->n )
	{
		return LIS_ERR_ILL_ARG;
	}

	if (A->is_splited)
	{
		LIS_SETERR_IMP;
		return LIS_ERR_NOT_IMPLEMENTED;
	} else {
		n = A->n;
		ptr = (LIS_INT *)lis_malloc( (n+1)*sizeof(LIS_INT),"lis_matmat_csr::ptr" );
		if( ptr==NULL )
		{
			LIS_SETERR_MEM((n+1)*sizeof(LIS_INT));
			lis_free(ptr);
			LIS_DEBUG_FUNC_OUT;
			return LIS_OUT_OF_MEMORY;
		}

		lis_csr_matmat_pass1(n, n, A->ptr, A->index, B->ptr, B->index, ptr);

		nnz = ptr[n];

		index = (LIS_INT *)lis_malloc( nnz*sizeof(LIS_INT),"lis_matmat_csr::index" );
		if( index==NULL )
		{
			LIS_SETERR_MEM(nnz*sizeof(LIS_INT));
			lis_free(index);
			return LIS_OUT_OF_MEMORY;
		}
		value = (LIS_SCALAR *)lis_malloc( nnz*sizeof(LIS_SCALAR),"lis_matmat_csr::value" );
		if( value==NULL )
		{
			LIS_SETERR_MEM(nnz*sizeof(LIS_SCALAR));
			lis_free(value);
			return LIS_OUT_OF_MEMORY;
		}

		lis_csr_matmat_pass2(n, n, A->ptr, A->index, A->value, B->ptr,
				B->index, B->value, ptr, index, value);

		err = lis_matrix_set_csr(nnz, ptr, index, value, C);
	}

	LIS_DEBUG_FUNC_OUT;
	return err;
}


