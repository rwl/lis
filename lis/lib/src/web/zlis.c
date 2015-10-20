#include <complex.h>
#include "lis.h"

LIS_INT zlis_vector_set_value(LIS_INT flag, LIS_INT i,
		LIS_REAL re, LIS_REAL im, LIS_VECTOR v) {
	LIS_SCALAR value = re + im * I;
	return lis_vector_set_value(flag, i, value, v);
}

LIS_INT zlis_vector_axpy(LIS_REAL re, LIS_REAL im, LIS_VECTOR vx,
		LIS_VECTOR vy) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_axpy(alpha, vx, vy);
}

LIS_INT zlis_vector_xpay(LIS_VECTOR vx, LIS_REAL re, LIS_REAL im,
		LIS_VECTOR vy) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_xpay(vx, alpha, vy);
}

LIS_INT zlis_vector_axpyz(LIS_REAL re, LIS_REAL im, LIS_VECTOR vx,
		LIS_VECTOR vy, LIS_VECTOR vz) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_axpyz(alpha, vx, vy, vz);
}

LIS_INT zlis_vector_scale(LIS_REAL re, LIS_REAL im, LIS_VECTOR vx) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_scale(alpha, vx);
}

LIS_INT zlis_vector_set_all(LIS_REAL re, LIS_REAL im, LIS_VECTOR vx) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_set_all(alpha, vx);
}

LIS_INT zlis_vector_shift(LIS_REAL re, LIS_REAL im, LIS_VECTOR vx) {
	LIS_SCALAR alpha = re + im * I;
	return lis_vector_shift(alpha, vx);
}

LIS_INT zlis_matrix_set_value(LIS_INT flag, LIS_INT i, LIS_INT j,
		LIS_REAL re, LIS_REAL im, LIS_MATRIX A) {
	LIS_SCALAR value = re + im * I;
	return lis_matrix_set_value(flag, i, j, value, A);
}
