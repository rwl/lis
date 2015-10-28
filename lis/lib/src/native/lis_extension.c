#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#ifdef HAVE_CONFIG_H
        #include "lis_config.h"
#else
#ifdef HAVE_CONFIG_WIN_H
        #include "lis_config_win.h"
#endif
#endif

#include "lis.h"
#include "dart_api.h"


Dart_NativeFunction ResolveName(Dart_Handle name, int argc,
    bool* auto_setup_scope);

#if defined(_COMPLEX)
DART_EXPORT Dart_Handle zlis_extension_Init(Dart_Handle parent_library)
#else
DART_EXPORT Dart_Handle dlis_extension_Init(Dart_Handle parent_library)
#endif
{
  if (Dart_IsError(parent_library)) {
    return parent_library;
  }

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName,
      NULL);
  if (Dart_IsError(result_code)) {
    return result_code;
  }

  return Dart_Null();
}


Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}


Dart_Handle Dart_GetNativeUint64Argument(Dart_NativeArguments args, int index,
    uint64_t* value) {
  Dart_Handle obj = HandleError(Dart_GetNativeArgument(args, index));
  if (Dart_IsInteger(obj)) {
    bool fits;
    HandleError(Dart_IntegerFitsIntoUint64(obj, &fits));
    if (fits) {
      HandleError(Dart_IntegerToUint64(obj, value));
    } else {
      return Dart_NewApiError("expected uint64_t");
    }
  } else {
    return Dart_NewApiError("expected integer");
  }
  return Dart_Null();
}


void Dart_SetUint64ReturnValue(Dart_NativeArguments args, uint64_t retval) {
  Dart_Handle result;
  result = HandleError(Dart_NewIntegerFromUint64(retval));
  Dart_SetReturnValue(args, result);
}


void Dart_SetLisScalarReturnValue(Dart_NativeArguments args,
    LIS_SCALAR retval) {
  Dart_Handle result;
#if defined(_COMPLEX)
  Dart_Handle url, lib, klass;

  url = Dart_NewStringFromCString("package:complex/src/complex.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Complex")));
  Dart_Handle arg[2] = {
    HandleError(Dart_NewDouble(creal(retval))),
    HandleError(Dart_NewDouble(cimag(retval)))
  };
  result = HandleError(Dart_New(klass, Dart_Null(), 2, arg));
#else
  result = HandleError(Dart_NewDouble(retval));
#endif
  Dart_SetReturnValue(args, result);
}


void Dart_SetLisScalarArrayReturnValue(Dart_NativeArguments args,
    LIS_SCALAR retval[], intptr_t length) {
  Dart_Handle result;

#if defined(_COMPLEX)
  Dart_Handle url, lib, klass, value;
  intptr_t i;

  url = Dart_NewStringFromCString("package:complex/src/complex.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Complex")));

  result = HandleError(Dart_NewList(length));
  for (i = 0; i < length; i++) {
    Dart_Handle arg[2] = {
      HandleError(Dart_NewDouble(creal(retval[i]))),
      HandleError(Dart_NewDouble(cimag(retval[i])))
    };
    value = HandleError(Dart_New(klass, Dart_Null(), 2, arg));

    HandleError(Dart_ListSetAt(result, i, value));
  }
#else
  result = HandleError(Dart_NewExternalTypedData(Dart_TypedData_kFloat64,
      retval, length));
#endif

  Dart_SetReturnValue(args, result);
}


void Dart_GetNativeVectorArgument(Dart_NativeArguments args, int index,
    LIS_VECTOR* value) {
  uint64_t ptr;
  HandleError(Dart_GetNativeUint64Argument(args, index, &ptr));
  *value = (LIS_VECTOR) ptr;
}


void Dart_GetNativeMatrixArgument(Dart_NativeArguments args, int index,
    LIS_MATRIX* value) {
  uint64_t ptr;
  HandleError(Dart_GetNativeUint64Argument(args, index, &ptr));
  *value = (LIS_MATRIX) ptr;
}


void Dart_GetNativeSolverArgument(Dart_NativeArguments args, int index,
    LIS_SOLVER* value) {
  uint64_t ptr;
  HandleError(Dart_GetNativeUint64Argument(args, index, &ptr));
  *value = (LIS_SOLVER) ptr;
}


void Dart_GetNativeEsolverArgument(Dart_NativeArguments args, int index,
    LIS_ESOLVER* value) {
  uint64_t ptr;
  HandleError(Dart_GetNativeUint64Argument(args, index, &ptr));
  *value = (LIS_ESOLVER) ptr;
}


void Dart_GetNativeLisIntArgument(Dart_NativeArguments args, int index,
    LIS_INT* value) {
  int64_t v;
  HandleError(Dart_GetNativeIntegerArgument(args, index, &v));
  *value = (LIS_INT) v;
}


void Dart_GetNativeLisScalarArgument(Dart_NativeArguments args, int index,
    LIS_SCALAR* value) {
  LIS_SCALAR v;
#if defined(_COMPLEX)
  Dart_Handle url, lib, klass, obj, real_obj, imag_obj;
  double real, imag;
  bool instanceof;

  url = Dart_NewStringFromCString("package:complex/src/complex.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Complex")));

  obj = HandleError(Dart_GetNativeArgument(args, index));

  HandleError(Dart_ObjectIsType(obj, klass, &instanceof));
  if (instanceof) {
    real_obj = HandleError(Dart_GetField(obj, Dart_NewStringFromCString("real")));
    imag_obj = HandleError(Dart_GetField(obj, Dart_NewStringFromCString("imaginary")));

    HandleError(Dart_DoubleValue(real_obj, &real));
    HandleError(Dart_DoubleValue(imag_obj, &imag));
    v = real + imag * I;
  } else {
    HandleError(Dart_NewApiError("expected Complex"));
  }

#else
  HandleError(Dart_GetNativeDoubleArgument(args, index, &v));
#endif
  *value = v;
}


void Dart_GetNativeLisIntArrayArgument(Dart_NativeArguments args, int index,
    LIS_INT* value[]) {
  Dart_Handle obj, val;
  Dart_TypedData_Type type;
  void* data;
  intptr_t len, i;
  int32_t* dataP;
  bool fits;
  int64_t val2;

  obj = HandleError(Dart_GetNativeArgument(args, index));
  if (Dart_IsNull(obj)) {
    *value = NULL;
  } else if (Dart_IsTypedData(obj)) {
    if (Dart_GetTypeOfTypedData(obj) != Dart_TypedData_kInt32) {
      HandleError(Dart_NewApiError("expected Int32List"));
    }
    HandleError(Dart_TypedDataAcquireData(obj, &type, &data, &len));
    dataP = (int32_t*) data;
    *value = (LIS_INT*) malloc(sizeof(LIS_INT) * len);
    for (i = 0; i < len; i++) {
      (*value)[i] = (LIS_INT) dataP[i];
    }
    HandleError(Dart_TypedDataReleaseData(obj));
  } else if (Dart_IsList(obj)) {
    HandleError(Dart_ListLength(obj, &len));
    *value = (LIS_INT*) malloc(sizeof(LIS_INT) * len);
    for (i = 0; i < len; i++) {
      val = HandleError(Dart_ListGetAt(obj, i));
      if (Dart_IsInteger(val)) {
        HandleError(Dart_IntegerFitsIntoInt64(val, &fits));
        if (fits) {
          HandleError(Dart_IntegerToInt64(val, &val2));
          (*value)[i] = (LIS_INT) val2;
        } else {
          HandleError(Dart_NewApiError("expected List<int>"));
        }
      }
    }
  } else {
    HandleError(Dart_NewApiError("expected List"));
  }
}


void Dart_GetNativeLisScalarArrayArgument(Dart_NativeArguments args, int index,
    LIS_SCALAR* value[]) {
  Dart_Handle obj, val;
  intptr_t len, i;
#if defined(_COMPLEX)
  Dart_Handle url, lib, klass;
  bool instanceof;
  Dart_Handle real_obj, imag_obj;
  double real, imag;
#else
  Dart_TypedData_Type type;
  void* data;
  double* dataP;
  double val2;
#endif

  obj = HandleError(Dart_GetNativeArgument(args, index));

  if (Dart_IsList(obj)) {
	HandleError(Dart_ListLength(obj, &len));
	*value = (LIS_SCALAR*) malloc(sizeof(LIS_SCALAR) * len);

#if defined(_COMPLEX)
    url = Dart_NewStringFromCString("package:complex/src/complex.dart");
    lib = HandleError(Dart_LookupLibrary(url));
    klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Complex")));
#endif

    for (i = 0; i < len; i++) {
      val = HandleError(Dart_ListGetAt(obj, i));
#if defined(_COMPLEX)
      HandleError(Dart_ObjectIsType(val, klass, &instanceof));
      if (instanceof) {
        real_obj = HandleError(Dart_GetField(val, Dart_NewStringFromCString("real")));
        imag_obj = HandleError(Dart_GetField(val, Dart_NewStringFromCString("imaginary")));

        HandleError(Dart_DoubleValue(real_obj, &real));
        HandleError(Dart_DoubleValue(imag_obj, &imag));

        (*value)[i] = real + imag * I;
      } else {
        HandleError(Dart_NewApiError("expected List<Complex>"));
      }
#else
      if (Dart_IsDouble(val)) {
        HandleError(Dart_DoubleValue(val, &val2));
        (*value)[i] = (LIS_SCALAR) val2;
      } else {
        HandleError(Dart_NewApiError("expected List<double>"));
      }
#endif
    }
  } else if (Dart_IsTypedData(obj)) {
#if defined(_COMPLEX)
    HandleError(Dart_NewApiError("expected List<Complex>"));
#else
    if (Dart_GetTypeOfTypedData(obj) != Dart_TypedData_kFloat64) {
      HandleError(Dart_NewApiError("expected Float64List"));
    }
    HandleError(Dart_TypedDataAcquireData(obj, &type, &data, &len));
    dataP = (double*) data;
    *value = (LIS_SCALAR*) malloc(sizeof(LIS_SCALAR) * len);
    for (i = 0; i < len; i++) {
      (*value)[i] = (LIS_SCALAR) dataP[i];
    }
    HandleError(Dart_TypedDataReleaseData(obj));
#endif
  } else {
    HandleError(Dart_NewApiError("expected List"));
  }
}


void LIS_Initialize(Dart_NativeArguments arguments) {
  LIS_INT err, argc;
  char* argv[] = { "lis", NULL };
  char** p_argv;

  Dart_EnterScope();
  argc = 1;
  p_argv = &argv[0];
  err = lis_initialize(&argc, &p_argv); CHKERR(err);
  Dart_ExitScope();
}


void LIS_Finalize(Dart_NativeArguments arguments) {
  LIS_INT err;
  Dart_EnterScope();
  err = lis_finalize(); CHKERR(err);
  Dart_ExitScope();
}


void LIS_VectorCreate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  err = lis_vector_create(LIS_COMM_WORLD, &vec); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) vec);
  Dart_ExitScope();
}


void LIS_VectorSetSize(Dart_NativeArguments arguments) {
  LIS_INT err, n;
  LIS_VECTOR vec;

  Dart_EnterScope();

  Dart_GetNativeVectorArgument(arguments, 1, &vec);
  Dart_GetNativeLisIntArgument(arguments, 2, &n);

  err = lis_vector_set_size(vec, n, n); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_destroy(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorDuplicate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vout, vin;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vin);

  err = lis_vector_duplicate(vin, &vout); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) vout);
  Dart_ExitScope();
}


void LIS_VectorGetSize(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vin;
  LIS_INT loc_n, glob_n;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vin);

  err = lis_vector_get_size(vin, &loc_n, &glob_n); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) loc_n);
  Dart_ExitScope();
}


void LIS_VectorGetValue(Dart_NativeArguments arguments) {
  LIS_INT err, i;
  LIS_VECTOR vin;
  LIS_SCALAR value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vin);
  Dart_GetNativeLisIntArgument(arguments, 2, &i);

  err = lis_vector_get_value(vin, i, &value); CHKERR(err);

  Dart_SetLisScalarReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorGetValues(Dart_NativeArguments arguments) {
  LIS_INT err, start, count;
  LIS_VECTOR vec;
  LIS_SCALAR *value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);
  Dart_GetNativeLisIntArgument(arguments, 2, &start);
  Dart_GetNativeLisIntArgument(arguments, 3, &count);

  value = (LIS_SCALAR *) malloc(sizeof(LIS_SCALAR) * count);

  err = lis_vector_get_values(vec, start, count, value); CHKERR(err);

  Dart_SetLisScalarArrayReturnValue(arguments, value, (intptr_t) count);
  Dart_ExitScope();
}


void LIS_VectorSetValue(Dart_NativeArguments arguments) {
  LIS_INT err, flag, i;
  LIS_VECTOR vin;
  LIS_SCALAR value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &flag);
  Dart_GetNativeLisIntArgument(arguments, 2, &i);
  Dart_GetNativeLisScalarArgument(arguments, 3, &value);
  Dart_GetNativeVectorArgument(arguments, 4, &vin);

  err = lis_vector_set_value(flag, i, value, vin); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorSetValues(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_INT flag, count, *index;
  LIS_SCALAR *value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &flag);
  Dart_GetNativeLisIntArgument(arguments, 2, &count);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeVectorArgument(arguments, 5, &vec);

  err = lis_vector_set_values(flag, count, index, value, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorSetValues2(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_INT flag, start, count;
  LIS_SCALAR* value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &flag);
  Dart_GetNativeLisIntArgument(arguments, 2, &start);
  Dart_GetNativeLisIntArgument(arguments, 3, &count);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeVectorArgument(arguments, 5, &vec);

  err = lis_vector_set_values2(flag, start, count, value, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorPrint(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_print(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorIsNull(Dart_NativeArguments arguments) {
  LIS_INT retval;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  retval = lis_vector_is_null(vec);

  Dart_SetIntegerReturnValue(arguments, (int64_t) retval);
  Dart_ExitScope();
}


void LIS_VectorSwap(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vsrc, vdst;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vsrc);
  Dart_GetNativeVectorArgument(arguments, 2, &vdst);

  err = lis_vector_swap(vsrc, vdst); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorCopy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vsrc, vdst;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vsrc);
  Dart_GetNativeVectorArgument(arguments, 2, &vdst);

  err = lis_vector_copy(vsrc, vdst); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorAxpy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArgument(arguments, 1, &alpha);
  Dart_GetNativeVectorArgument(arguments, 2, &vx);
  Dart_GetNativeVectorArgument(arguments, 3, &vy);

  err = lis_vector_axpy(alpha, vx, vy); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorXpay(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vx);
  Dart_GetNativeLisScalarArgument(arguments, 2, &alpha);
  Dart_GetNativeVectorArgument(arguments, 3, &vy);

  err = lis_vector_xpay(vx, alpha, vy); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorAxpyz(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy, vz;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArgument(arguments, 1, &alpha);
  Dart_GetNativeVectorArgument(arguments, 2, &vx);
  Dart_GetNativeVectorArgument(arguments, 3, &vy);
  Dart_GetNativeVectorArgument(arguments, 4, &vz);

  err = lis_vector_axpyz(alpha, vx, vy, vz); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorScale(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArgument(arguments, 1, &alpha);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_vector_scale(alpha, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorPmul(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy, vz;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vx);
  Dart_GetNativeVectorArgument(arguments, 2, &vy);
  Dart_GetNativeVectorArgument(arguments, 3, &vz);

  err = lis_vector_pmul(vx, vy, vz); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorPdiv(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy, vz;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vx);
  Dart_GetNativeVectorArgument(arguments, 2, &vy);
  Dart_GetNativeVectorArgument(arguments, 3, &vz);

  err = lis_vector_pdiv(vx, vy, vz); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorSetAll(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArgument(arguments, 1, &alpha);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_vector_set_all(alpha, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorAbs(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_abs(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorReciprocal(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_reciprocal(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}

void LIS_VectorShift(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArgument(arguments, 1, &alpha);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_vector_shift(alpha, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorDot(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vx, vy;
  LIS_SCALAR value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vx);
  Dart_GetNativeVectorArgument(arguments, 2, &vy);

  err = lis_vector_dot(vx, vy, &value); CHKERR(err);

  Dart_SetLisScalarReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorNrm1(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_REAL value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_nrm1(vec, &value); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorNrm2(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_REAL value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_nrm2(vec, &value); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorNrmi(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_REAL value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_nrmi(vec, &value); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorSum(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_SCALAR value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_sum(vec, &value); CHKERR(err);

  Dart_SetLisScalarReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorReal(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_real(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorImaginary(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_imaginary(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorArgument(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_argument(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_VectorConjugate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_conjugate(vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixCreate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX mat;

  Dart_EnterScope();
  err = lis_matrix_create(LIS_COMM_WORLD, &mat); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) mat);
  Dart_ExitScope();
}


void LIS_MatrixDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  err = lis_matrix_destroy(mat); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixAssemble(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  err = lis_matrix_assemble(mat); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixIsAssembled(Dart_NativeArguments arguments) {
  LIS_INT retval;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  retval = lis_matrix_is_assembled(mat);

  Dart_SetIntegerReturnValue(arguments, (int64_t) retval);
  Dart_ExitScope();
}


void LIS_MatrixDuplicate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX Ain, Aout;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &Ain);

  err = lis_matrix_duplicate(Ain, &Aout); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) Aout);
  Dart_ExitScope();
}


void LIS_MatrixSetSize(Dart_NativeArguments arguments) {
  LIS_INT err, n;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);
  Dart_GetNativeLisIntArgument(arguments, 2, &n);

  err = lis_matrix_set_size(mat, n, n); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixGetSize(Dart_NativeArguments arguments) {
  LIS_INT err, loc_n, glob_n;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  err = lis_matrix_get_size(mat, &loc_n, &glob_n); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) loc_n);
  Dart_ExitScope();
}


void LIS_MatrixGetNnz(Dart_NativeArguments arguments) {
  LIS_INT err, nnz;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  err = lis_matrix_get_nnz(mat, &nnz); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) nnz);
  Dart_ExitScope();
}


void LIS_MatrixSetType(Dart_NativeArguments arguments) {
  LIS_INT err, matrix_type;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);
  Dart_GetNativeLisIntArgument(arguments, 2, &matrix_type);

  err = lis_matrix_set_type(mat, matrix_type); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixGetType(Dart_NativeArguments arguments) {
  LIS_INT err, matrix_type;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);

  err = lis_matrix_get_type(mat, &matrix_type); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) matrix_type);
  Dart_ExitScope();
}


void LIS_MatrixSetValue(Dart_NativeArguments arguments) {
  LIS_INT err, flag, i, j;
  LIS_MATRIX mat;
  LIS_SCALAR value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &flag);
  Dart_GetNativeLisIntArgument(arguments, 2, &i);
  Dart_GetNativeLisIntArgument(arguments, 3, &j);
  Dart_GetNativeLisScalarArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 5, &mat);

  err = lis_matrix_set_value(flag, i, j, value, mat); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetValues(Dart_NativeArguments arguments) {
  LIS_INT err, flag, n;
  LIS_MATRIX mat;
  LIS_SCALAR *values;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &flag);
  Dart_GetNativeLisIntArgument(arguments, 2, &n);
  Dart_GetNativeLisScalarArrayArgument(arguments, 3, &values);
  Dart_GetNativeMatrixArgument(arguments, 4, &mat);

  err = lis_matrix_set_values(flag, n, values, mat); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixMalloc(Dart_NativeArguments arguments) {
  LIS_INT err, nnz_row, *nnz;
  LIS_MATRIX mat;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);
  Dart_GetNativeLisIntArgument(arguments, 2, &nnz_row);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &nnz);

  err = lis_matrix_malloc(mat, nnz_row, nnz); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixGetDiagonal(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX mat;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &mat);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_matrix_get_diagonal(mat, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixConvert(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX Ain, Aout;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &Ain);
  Dart_GetNativeMatrixArgument(arguments, 2, &Aout);

  err = lis_matrix_convert(Ain, Aout); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixCopy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX Ain, Aout;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &Ain);
  Dart_GetNativeMatrixArgument(arguments, 2, &Aout);

  err = lis_matrix_copy(Ain, Aout); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixTranspose(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX Ain, Aout;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &Ain);
  Dart_GetNativeMatrixArgument(arguments, 2, &Aout);

  err = lis_matrix_transpose(Ain, Aout); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSumDuplicates(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_sum_duplicates(A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSortIndexes(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_sort_indexes(A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixCompose(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A, B, C, D, Y;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeMatrixArgument(arguments, 2, &B);
  Dart_GetNativeMatrixArgument(arguments, 3, &C);
  Dart_GetNativeMatrixArgument(arguments, 4, &D);
  Dart_GetNativeMatrixArgument(arguments, 5, &Y);

  err = lis_matrix_compose(A, B, C, D, Y); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixReal(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_real(A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixImaginary(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_imaginary(A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixConjugate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_conjugate(A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixScaleValues(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeLisScalarArgument(arguments, 2, &alpha);

  err = lis_matrix_scale_values(A, alpha); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}



void LIS_MatrixSetCsr(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_INT nnz, *ptr, *index;
  LIS_SCALAR *value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 2, &ptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 5, &A);

  err = lis_matrix_set_csr(nnz, ptr, index, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetCsc(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_INT nnz, *ptr, *index;
  LIS_SCALAR *value;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 2, &ptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 5, &A);

  err = lis_matrix_set_csc(nnz, ptr, index, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetBsr(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT bnr, bnc, bnnz, *bptr, *bindex;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &bnr);
  Dart_GetNativeLisIntArgument(arguments, 2, &bnc);
  Dart_GetNativeLisIntArgument(arguments, 3, &bnnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 4, &bptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 5, &bindex);
  Dart_GetNativeLisScalarArrayArgument(arguments, 6, &value);
  Dart_GetNativeMatrixArgument(arguments, 7, &A);

  err = lis_matrix_set_bsr(bnr, bnc, bnnz, bptr, bindex, value, A);
  CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetMsr(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT nnz, ndz, *index;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArgument(arguments, 2, &ndz);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 5, &A);

  err = lis_matrix_set_msr(nnz, ndz, index, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetEll(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT maxnzr, *index;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &maxnzr);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 1, &A);

  err = lis_matrix_set_ell(maxnzr, index, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetJad(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT nnz, maxnzr, *perm, *ptr, *index;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArgument(arguments, 2, &maxnzr);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &perm);
  Dart_GetNativeLisIntArrayArgument(arguments, 4, &ptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 5, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 6, &value);
  Dart_GetNativeMatrixArgument(arguments, 7, &A);

  err = lis_matrix_set_jad(nnz, maxnzr, perm, ptr, index, value, A);
  CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetDia(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT nnd, *index;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnd);
  Dart_GetNativeLisIntArrayArgument(arguments, 2, &index);
  Dart_GetNativeLisScalarArrayArgument(arguments, 3, &value);
  Dart_GetNativeMatrixArgument(arguments, 4, &A);

  err = lis_matrix_set_dia(nnd, index, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetBsc(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT bnr, bnc, bnnz, *bptr, *bindex;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &bnr);
  Dart_GetNativeLisIntArgument(arguments, 2, &bnc);
  Dart_GetNativeLisIntArgument(arguments, 3, &bnnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 4, &bptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 5, &bindex);
  Dart_GetNativeLisScalarArrayArgument(arguments, 6, &value);
  Dart_GetNativeMatrixArgument(arguments, 7, &A);

  err = lis_matrix_set_bsc(bnr, bnc, bnnz, bptr, bindex, value, A);
  CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetVbr(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT nnz, nr, nc, bnnz, *row, *col, *ptr, *bptr, *bindex;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArgument(arguments, 2, &nr);
  Dart_GetNativeLisIntArgument(arguments, 3, &nc);
  Dart_GetNativeLisIntArgument(arguments, 4, &bnnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 5, &row);
  Dart_GetNativeLisIntArrayArgument(arguments, 6, &col);
  Dart_GetNativeLisIntArrayArgument(arguments, 7, &ptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 8, &bptr);
  Dart_GetNativeLisIntArrayArgument(arguments, 9, &bindex);
  Dart_GetNativeLisScalarArrayArgument(arguments, 10, &value);
  Dart_GetNativeMatrixArgument(arguments, 11, &A);

  err = lis_matrix_set_vbr(nnz, nr, nc, bnnz, row, col, ptr, bptr,
      bindex, value, A);
  CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetCoo(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_INT nnz, *row, *col;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisIntArgument(arguments, 1, &nnz);
  Dart_GetNativeLisIntArrayArgument(arguments, 2, &row);
  Dart_GetNativeLisIntArrayArgument(arguments, 3, &col);
  Dart_GetNativeLisScalarArrayArgument(arguments, 4, &value);
  Dart_GetNativeMatrixArgument(arguments, 5, &A);

  err = lis_matrix_set_coo(nnz, row, col, value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatrixSetDns(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SCALAR *value;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeLisScalarArrayArgument(arguments, 1, &value);
  Dart_GetNativeMatrixArgument(arguments, 2, &A);

  err = lis_matrix_set_dns(value, A); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatVec(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR X, Y;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &X);
  Dart_GetNativeVectorArgument(arguments, 3, &Y);

  err = lis_matvec(A, X, Y); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatVecT(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR X, Y;
  LIS_MATRIX A;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &X);
  Dart_GetNativeVectorArgument(arguments, 3, &Y);

  err = lis_matvect(A, X, Y); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_MatMat(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A, B, C;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeMatrixArgument(arguments, 2, &B);
  Dart_GetNativeMatrixArgument(arguments, 3, &C);

  err = lis_matmat(A, B, C); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_SolverCreate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;

  Dart_EnterScope();

  err = lis_solver_create(&solver); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) solver);
  Dart_ExitScope();
}


void LIS_SolverDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_destroy(solver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_SolverGetIter(Dart_NativeArguments arguments) {
  LIS_INT err, iter;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_iter(solver, &iter); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) iter);
  Dart_ExitScope();
}


void LIS_SolverGetIterEx(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  LIS_INT iter, iter_double, iter_quad;
  Dart_Handle url, lib, klass, result;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_iterex(solver, &iter, &iter_double, &iter_quad);
  CHKERR(err);

  url = Dart_NewStringFromCString("package:lis/src/lis.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Iter")));
  Dart_Handle arg[3] = {
    HandleError(Dart_NewInteger(iter)),
    HandleError(Dart_NewInteger(iter_double)),
    HandleError(Dart_NewInteger(iter_quad))
  };
  result = HandleError(Dart_New(klass, Dart_Null(), 3, arg));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


void LIS_SolverGetTime(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  double time;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_time(solver, &time); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, time);
  Dart_ExitScope();
}


void LIS_SolverGetTimeEx(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  double time, itime, ptime, p_c_time, p_i_time;
  Dart_Handle url, lib, klass, result;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_timeex(solver, &time, &itime, &ptime,
      &p_c_time, &p_i_time);
  CHKERR(err);

  url = Dart_NewStringFromCString("package:lis/src/lis.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Time")));
  Dart_Handle arg[5] = {
    HandleError(Dart_NewDouble(time)),
    HandleError(Dart_NewDouble(itime)),
    HandleError(Dart_NewDouble(ptime)),
    HandleError(Dart_NewDouble(p_c_time)),
    HandleError(Dart_NewDouble(p_i_time)),
  };
  result = HandleError(Dart_New(klass, Dart_Null(), 5, arg));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


void LIS_SolverGetResidualNorm(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  LIS_REAL residual;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_residualnorm(solver, &residual); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, residual);
  Dart_ExitScope();
}


void LIS_SolverGetSolver(Dart_NativeArguments arguments) {
  LIS_INT err, nsol;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_solver(solver, &nsol); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) nsol);
  Dart_ExitScope();
}


void LIS_SolverGetPrecon(Dart_NativeArguments arguments) {
  LIS_INT err, precon;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_precon(solver, &precon); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) precon);
  Dart_ExitScope();
}


void LIS_SolverGetStatus(Dart_NativeArguments arguments) {
  LIS_INT err, status;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_get_status(solver, &status); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) status);
  Dart_ExitScope();
}


void LIS_SolverGetRHistory(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_solver_get_rhistory(solver, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_SolverSetOption(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  Dart_Handle text_obj;
  const char *text;

  Dart_EnterScope();
  text_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_GetNativeSolverArgument(arguments, 2, &solver);

  HandleError(Dart_StringToCString(text_obj, &text));

  err = lis_solver_set_option((char *) text, solver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_SolverSetOptionC(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  err = lis_solver_set_optionC(solver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_Solve(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_VECTOR b, x;
  LIS_SOLVER solver;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &b);
  Dart_GetNativeVectorArgument(arguments, 3, &x);
  Dart_GetNativeSolverArgument(arguments, 4, &solver);

  err = lis_solve(A, b, x, solver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverCreate(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;

  Dart_EnterScope();

  err = lis_esolver_create(&esolver); CHKERR(err);

  Dart_SetUint64ReturnValue(arguments, (uint64_t) esolver);
  Dart_ExitScope();
}


void LIS_EsolverDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_destroy(esolver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverSetOption(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  Dart_Handle text_obj;
  const char *text;

  Dart_EnterScope();
  text_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_GetNativeEsolverArgument(arguments, 2, &esolver);

  HandleError(Dart_StringToCString(text_obj, &text));

  err = lis_esolver_set_option((char *) text, esolver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverSetOptionC(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_set_optionC(esolver); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_Esolve(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_VECTOR x;
  LIS_SCALAR evalue0;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &x);
  Dart_GetNativeEsolverArgument(arguments, 3, &esolver);

  err = lis_esolve(A, x, &evalue0, esolver); CHKERR(err);

  Dart_SetLisScalarReturnValue(arguments, evalue0);
  Dart_ExitScope();
}


void LIS_EsolverGetIter(Dart_NativeArguments arguments) {
  LIS_INT err, iter;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_iter(esolver, &iter); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) iter);
  Dart_ExitScope();
}


void LIS_EsolverGetIterEx(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_INT iter, iter_double, iter_quad;
  Dart_Handle url, lib, klass, result;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_iterex(esolver, &iter, &iter_double, &iter_quad);
  CHKERR(err);

  url = Dart_NewStringFromCString("package:lis/src/lis.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Iter")));
  Dart_Handle arg[3] = {
    HandleError(Dart_NewInteger(iter)),
    HandleError(Dart_NewInteger(iter_double)),
    HandleError(Dart_NewInteger(iter_quad))
  };
  result = HandleError(Dart_New(klass, Dart_Null(), 3, arg));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


void LIS_EsolverGetTime(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  double time;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_time(esolver, &time); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, time);
  Dart_ExitScope();
}


void LIS_EsolverGetTimeEx(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  double time, itime, ptime, p_c_time, p_i_time;
  Dart_Handle url, lib, klass, result;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_timeex(esolver, &time, &itime, &ptime,
      &p_c_time, &p_i_time);
  CHKERR(err);

  url = Dart_NewStringFromCString("package:lis/src/lis.dart");
  lib = HandleError(Dart_LookupLibrary(url));
  klass = HandleError(Dart_GetClass(lib, Dart_NewStringFromCString("Time")));
  Dart_Handle arg[5] = {
    HandleError(Dart_NewDouble(time)),
    HandleError(Dart_NewDouble(itime)),
    HandleError(Dart_NewDouble(ptime)),
    HandleError(Dart_NewDouble(p_c_time)),
    HandleError(Dart_NewDouble(p_i_time)),
  };
  result = HandleError(Dart_New(klass, Dart_Null(), 5, arg));

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


void LIS_EsolverGetResidualNorm(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_REAL residual;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_residualnorm(esolver, &residual); CHKERR(err);

  Dart_SetDoubleReturnValue(arguments, (double) residual);
  Dart_ExitScope();
}


void LIS_EsolverGetStatus(Dart_NativeArguments arguments) {
  LIS_INT err, status;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_status(esolver, &status); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) status);
  Dart_ExitScope();
}


void LIS_EsolverGetRHistory(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_esolver_get_rhistory(esolver, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverGetEvalues(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_esolver_get_evalues(esolver, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverGetEvectors(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_MATRIX M;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);
  Dart_GetNativeMatrixArgument(arguments, 2, &M);

  err = lis_esolver_get_evectors(esolver, M); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverGetResidualNorms(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_esolver_get_residualnorms(esolver, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverGetIters(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);
  Dart_GetNativeVectorArgument(arguments, 2, &vec);

  err = lis_esolver_get_iters(esolver, vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_EsolverGetEsolver(Dart_NativeArguments arguments) {
  LIS_INT err, nesol;
  LIS_ESOLVER esolver;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  err = lis_esolver_get_esolver(esolver, &nesol); CHKERR(err);

  Dart_SetIntegerReturnValue(arguments, (int64_t) nesol);
  Dart_ExitScope();
}


void LIS_Input(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  LIS_VECTOR b, x;
  Dart_Handle text_obj;
  const char *text;
  FILE *file;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &b);
  Dart_GetNativeVectorArgument(arguments, 3, &x);
  text_obj = HandleError(Dart_GetNativeArgument(arguments, 4));

  HandleError(Dart_StringToCString(text_obj, &text));

  file = fmemopen((void*) text, strlen(text), "r");
  if (file == NULL) {
    HandleError(Dart_NewApiError("fmemopen error"));
  }

  err = lis_input_file(A, b, x, file); CHKERR(err);

  fclose(file);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_InputMatrix(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_MATRIX A;
  Dart_Handle text_obj;
  const char *text;
  FILE *file;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  text_obj = HandleError(Dart_GetNativeArgument(arguments, 2));

  HandleError(Dart_StringToCString(text_obj, &text));

  file = fmemopen((void*) text, strlen(text), "r");
  if (file == NULL) {
    HandleError(Dart_NewApiError("fmemopen error"));
  }

  err = lis_input_matrix_file(A, file); CHKERR(err);

  fclose(file);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_InputVector(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;
  Dart_Handle text_obj;
  const char *text;
  FILE *file;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);
  text_obj = HandleError(Dart_GetNativeArgument(arguments, 2));

  HandleError(Dart_StringToCString(text_obj, &text));

  file = fmemopen((void*) text, strlen(text), "r");
  if (file == NULL) {
    HandleError(Dart_NewApiError("fmemopen error"));
  }

  err = lis_input_vector_file(vec, file); CHKERR(err);

  fclose(file);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}


void LIS_Output(Dart_NativeArguments arguments) {
  LIS_INT err, format;
  LIS_MATRIX A;
  LIS_VECTOR b, x;
  FILE *file;
  char *buf;
  size_t len;
  Dart_Handle text;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeVectorArgument(arguments, 2, &b);
  Dart_GetNativeVectorArgument(arguments, 3, &x);
  Dart_GetNativeLisIntArgument(arguments, 4, &format);

  file = open_memstream(&buf, &len);
  if (file == NULL) {
    HandleError(Dart_NewApiError("open_memstream error"));
  }

  err = lis_output_file(A, b, x, format, file); CHKERR(err);
  fflush (file);

  text = HandleError(Dart_NewStringFromCString((const char*) buf));

  Dart_SetReturnValue(arguments, text);

  fclose (file);
  free (buf);

  Dart_ExitScope();
}


void LIS_OutputMatrix(Dart_NativeArguments arguments) {
  LIS_INT err, format;
  LIS_MATRIX A;
  FILE *file;
  char *buf;
  size_t len;
  Dart_Handle text;

  Dart_EnterScope();
  Dart_GetNativeMatrixArgument(arguments, 1, &A);
  Dart_GetNativeLisIntArgument(arguments, 2, &format);

  file = open_memstream(&buf, &len);
  if (file == NULL) {
    HandleError(Dart_NewApiError("open_memstream error"));
  }

  err = lis_output_matrix_file(A, format, file); CHKERR(err);
  fflush (file);

  text = HandleError(Dart_NewStringFromCString((const char*) buf));

  Dart_SetReturnValue(arguments, text);

  fclose (file);
  free (buf);
  Dart_ExitScope();
}


void LIS_OutputVector(Dart_NativeArguments arguments) {
  LIS_INT err, format;
  LIS_VECTOR x;
  FILE *file;
  char *buf;
  size_t len;
  Dart_Handle text;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &x);
  Dart_GetNativeLisIntArgument(arguments, 2, &format);

  file = open_memstream(&buf, &len);
  if (file == NULL) {
    HandleError(Dart_NewApiError("open_memstream error"));
  }

  err = lis_output_vector_file(x, format, file); CHKERR(err);
  fflush (file);

  text = HandleError(Dart_NewStringFromCString((const char*) buf));

  Dart_SetReturnValue(arguments, text);

  fclose (file);
  free (buf);
  Dart_ExitScope();
}


void LIS_SolverOutputRHistory(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_SOLVER solver;
  FILE *file;
  char *buf;
  size_t len;
  Dart_Handle text;

  Dart_EnterScope();
  Dart_GetNativeSolverArgument(arguments, 1, &solver);

  file = open_memstream(&buf, &len);
  if (file == NULL) {
    HandleError(Dart_NewApiError("open_memstream error"));
  }

  err = lis_solver_output_rhistory_file(solver, file); CHKERR(err);
  fflush (file);

  text = HandleError(Dart_NewStringFromCString((const char*) buf));

  Dart_SetReturnValue(arguments, text);

  fclose (file);
  free (buf);
  Dart_ExitScope();
}


void LIS_EsolverOutputRHistory(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_ESOLVER esolver;
  FILE *file;
  char *buf;
  size_t len;
  Dart_Handle text;

  Dart_EnterScope();
  Dart_GetNativeEsolverArgument(arguments, 1, &esolver);

  file = open_memstream(&buf, &len);
  if (file == NULL) {
    HandleError(Dart_NewApiError("open_memstream error"));
  }

  err = lis_esolver_output_rhistory_file(esolver, file); CHKERR(err);
  fflush (file);

  text = HandleError(Dart_NewStringFromCString((const char*) buf));

  Dart_SetReturnValue(arguments, text);

  fclose (file);
  free (buf);
  Dart_ExitScope();
}


Dart_NativeFunction ResolveName(Dart_Handle name, int argc,
    bool* auto_setup_scope) {
  if (!Dart_IsString(name)) {
    return NULL;
  }
  Dart_NativeFunction result = NULL;
  if (auto_setup_scope == NULL) {
    return NULL;
  }

  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  if (strcmp("LIS_Initialize", cname) == 0) result = LIS_Initialize;
  if (strcmp("LIS_Finalize", cname) == 0) result = LIS_Finalize;
  if (strcmp("LIS_VectorCreate", cname) == 0) result = LIS_VectorCreate;
  if (strcmp("LIS_VectorSetSize", cname) == 0) result = LIS_VectorSetSize;
  if (strcmp("LIS_VectorDestroy", cname) == 0) result = LIS_VectorDestroy;
  if (strcmp("LIS_VectorDuplicate", cname) == 0) result = LIS_VectorDuplicate;
  if (strcmp("LIS_VectorGetSize", cname) == 0) result = LIS_VectorGetSize;
  if (strcmp("LIS_VectorGetValue", cname) == 0) result = LIS_VectorGetValue;
  if (strcmp("LIS_VectorGetValues", cname) == 0) result = LIS_VectorGetValues;
  if (strcmp("LIS_VectorSetValue", cname) == 0) result = LIS_VectorSetValue;
  if (strcmp("LIS_VectorSetValues", cname) == 0) result = LIS_VectorSetValues;
  if (strcmp("LIS_VectorSetValues2", cname) == 0) result = LIS_VectorSetValues2;
  if (strcmp("LIS_VectorSetAll", cname) == 0) result = LIS_VectorSetAll;
  if (strcmp("LIS_VectorPrint", cname) == 0) result = LIS_VectorPrint;
  if (strcmp("LIS_VectorIsNull", cname) == 0) result = LIS_VectorIsNull;
  if (strcmp("LIS_VectorSwap", cname) == 0) result = LIS_VectorSwap;
  if (strcmp("LIS_VectorCopy", cname) == 0) result = LIS_VectorCopy;
  if (strcmp("LIS_VectorAxpy", cname) == 0) result = LIS_VectorAxpy;
  if (strcmp("LIS_VectorXpay", cname) == 0) result = LIS_VectorXpay;
  if (strcmp("LIS_VectorAxpyz", cname) == 0) result = LIS_VectorAxpyz;
  if (strcmp("LIS_VectorScale", cname) == 0) result = LIS_VectorScale;
  if (strcmp("LIS_VectorPmul", cname) == 0) result = LIS_VectorPmul;
  if (strcmp("LIS_VectorPdiv", cname) == 0) result = LIS_VectorPdiv;
  if (strcmp("LIS_VectorAbs", cname) == 0) result = LIS_VectorAbs;
  if (strcmp("LIS_VectorReciprocal", cname) == 0) result = LIS_VectorReciprocal;
  if (strcmp("LIS_VectorShift", cname) == 0) result = LIS_VectorShift;
  if (strcmp("LIS_VectorDot", cname) == 0) result = LIS_VectorDot;
  if (strcmp("LIS_VectorNrm1", cname) == 0) result = LIS_VectorNrm1;
  if (strcmp("LIS_VectorNrm2", cname) == 0) result = LIS_VectorNrm2;
  if (strcmp("LIS_VectorNrmi", cname) == 0) result = LIS_VectorNrmi;
  if (strcmp("LIS_VectorSum", cname) == 0) result = LIS_VectorSum;
  if (strcmp("LIS_VectorReal", cname) == 0) result = LIS_VectorReal;
  if (strcmp("LIS_VectorImaginary", cname) == 0) result = LIS_VectorImaginary;
  if (strcmp("LIS_VectorArgument", cname) == 0) result = LIS_VectorArgument;
  if (strcmp("LIS_VectorConjugate", cname) == 0) result = LIS_VectorConjugate;

  if (strcmp("LIS_MatrixCreate", cname) == 0) result = LIS_MatrixCreate;
  if (strcmp("LIS_MatrixDestroy", cname) == 0) result = LIS_MatrixDestroy;
  if (strcmp("LIS_MatrixAssemble", cname) == 0) result = LIS_MatrixAssemble;
  if (strcmp("LIS_MatrixIsAssembled", cname) == 0) result = LIS_MatrixIsAssembled;
  if (strcmp("LIS_MatrixDuplicate", cname) == 0) result = LIS_MatrixDuplicate;
  if (strcmp("LIS_MatrixSetSize", cname) == 0) result = LIS_MatrixSetSize;
  if (strcmp("LIS_MatrixGetSize", cname) == 0) result = LIS_MatrixGetSize;
  if (strcmp("LIS_MatrixGetNnz", cname) == 0) result = LIS_MatrixGetNnz;
  if (strcmp("LIS_MatrixSetType", cname) == 0) result = LIS_MatrixSetType;
  if (strcmp("LIS_MatrixGetType", cname) == 0) result = LIS_MatrixGetType;
  if (strcmp("LIS_MatrixSetValue", cname) == 0) result = LIS_MatrixSetValue;
  if (strcmp("LIS_MatrixSetValues", cname) == 0) result = LIS_MatrixSetValues;
  if (strcmp("LIS_MatrixMalloc", cname) == 0) result = LIS_MatrixMalloc;
  if (strcmp("LIS_MatrixGetDiagonal", cname) == 0) result = LIS_MatrixGetDiagonal;
  if (strcmp("LIS_MatrixConvert", cname) == 0) result = LIS_MatrixConvert;
  if (strcmp("LIS_MatrixCopy", cname) == 0) result = LIS_MatrixCopy;
  if (strcmp("LIS_MatrixTranspose", cname) == 0) result = LIS_MatrixTranspose;
  if (strcmp("LIS_MatrixSumDuplicates", cname) == 0) result = LIS_MatrixSumDuplicates;
  if (strcmp("LIS_MatrixSortIndexes", cname) == 0) result = LIS_MatrixSortIndexes;
  if (strcmp("LIS_MatrixCompose", cname) == 0) result = LIS_MatrixCompose;
  if (strcmp("LIS_MatrixReal", cname) == 0) result = LIS_MatrixReal;
  if (strcmp("LIS_MatrixImaginary", cname) == 0) result = LIS_MatrixImaginary;
  if (strcmp("LIS_MatrixConjugate", cname) == 0) result = LIS_MatrixConjugate;
  if (strcmp("LIS_MatrixScaleValues", cname) == 0) result = LIS_MatrixScaleValues;

  if (strcmp("LIS_MatrixSetCsr", cname) == 0) result = LIS_MatrixSetCsr;
  if (strcmp("LIS_MatrixSetCsc", cname) == 0) result = LIS_MatrixSetCsc;
  if (strcmp("LIS_MatrixSetBsr", cname) == 0) result = LIS_MatrixSetBsr;
  if (strcmp("LIS_MatrixSetMsr", cname) == 0) result = LIS_MatrixSetMsr;
  if (strcmp("LIS_MatrixSetEll", cname) == 0) result = LIS_MatrixSetEll;
  if (strcmp("LIS_MatrixSetJad", cname) == 0) result = LIS_MatrixSetJad;
  if (strcmp("LIS_MatrixSetDia", cname) == 0) result = LIS_MatrixSetDia;
  if (strcmp("LIS_MatrixSetBsc", cname) == 0) result = LIS_MatrixSetBsc;
  if (strcmp("LIS_MatrixSetVbr", cname) == 0) result = LIS_MatrixSetVbr;
  if (strcmp("LIS_MatrixSetCoo", cname) == 0) result = LIS_MatrixSetCoo;
  if (strcmp("LIS_MatrixSetDns", cname) == 0) result = LIS_MatrixSetDns;

  if (strcmp("LIS_MatVec", cname) == 0) result = LIS_MatVec;
  if (strcmp("LIS_MatVecT", cname) == 0) result = LIS_MatVecT;

  if (strcmp("LIS_MatMat", cname) == 0) result = LIS_MatMat;

  if (strcmp("LIS_SolverCreate", cname) == 0) result = LIS_SolverCreate;
  if (strcmp("LIS_SolverDestroy", cname) == 0) result = LIS_SolverDestroy;
  if (strcmp("LIS_SolverGetIter", cname) == 0) result = LIS_SolverGetIter;
  if (strcmp("LIS_SolverGetIterEx", cname) == 0) result = LIS_SolverGetIterEx;
  if (strcmp("LIS_SolverGetTime", cname) == 0) result = LIS_SolverGetTime;
  if (strcmp("LIS_SolverGetTimeEx", cname) == 0) result = LIS_SolverGetTimeEx;
  if (strcmp("LIS_SolverGetResidualNorm", cname) == 0) result = LIS_SolverGetResidualNorm;
  if (strcmp("LIS_SolverGetSolver", cname) == 0) result = LIS_SolverGetSolver;
  if (strcmp("LIS_SolverGetPrecon", cname) == 0) result = LIS_SolverGetPrecon;
  if (strcmp("LIS_SolverGetStatus", cname) == 0) result = LIS_SolverGetStatus;
  if (strcmp("LIS_SolverGetRHistory", cname) == 0) result = LIS_SolverGetRHistory;
  if (strcmp("LIS_SolverSetOption", cname) == 0) result = LIS_SolverSetOption;
  if (strcmp("LIS_SolverSetOptionC", cname) == 0) result = LIS_SolverSetOptionC;
  if (strcmp("LIS_Solve", cname) == 0) result = LIS_Solve;

  if (strcmp("LIS_EsolverCreate", cname) == 0) result = LIS_EsolverCreate;
  if (strcmp("LIS_EsolverDestroy", cname) == 0) result = LIS_EsolverDestroy;
  if (strcmp("LIS_EsolverSetOption", cname) == 0) result = LIS_EsolverSetOption;
  if (strcmp("LIS_EsolverSetOptionC", cname) == 0) result = LIS_EsolverSetOptionC;
  if (strcmp("LIS_Esolve", cname) == 0) result = LIS_Esolve;
  if (strcmp("LIS_EsolverGetIter", cname) == 0) result = LIS_EsolverGetIter;
  if (strcmp("LIS_EsolverGetIterEx", cname) == 0) result = LIS_EsolverGetIterEx;
  if (strcmp("LIS_EsolverGetTime", cname) == 0) result = LIS_EsolverGetTime;
  if (strcmp("LIS_EsolverGetTimeEx", cname) == 0) result = LIS_EsolverGetTimeEx;
  if (strcmp("LIS_EsolverGetResidualNorm", cname) == 0) result = LIS_EsolverGetResidualNorm;
  if (strcmp("LIS_EsolverGetStatus", cname) == 0) result = LIS_EsolverGetStatus;
  if (strcmp("LIS_EsolverGetRHistory", cname) == 0) result = LIS_EsolverGetRHistory;
  if (strcmp("LIS_EsolverGetEvalues", cname) == 0) result = LIS_EsolverGetEvalues;
  if (strcmp("LIS_EsolverGetEvectors", cname) == 0) result = LIS_EsolverGetEvectors;
  if (strcmp("LIS_EsolverGetResidualNorms", cname) == 0) result = LIS_EsolverGetResidualNorms;
  if (strcmp("LIS_EsolverGetIters", cname) == 0) result = LIS_EsolverGetIters;
  if (strcmp("LIS_EsolverGetEsolver", cname) == 0) result = LIS_EsolverGetEsolver;

  if (strcmp("LIS_Input", cname) == 0) result = LIS_Input;
  if (strcmp("LIS_InputMatrix", cname) == 0) result = LIS_InputMatrix;
  if (strcmp("LIS_InputVector", cname) == 0) result = LIS_InputVector;
  if (strcmp("LIS_Output", cname) == 0) result = LIS_Output;
  if (strcmp("LIS_OutputMatrix", cname) == 0) result = LIS_OutputMatrix;
  if (strcmp("LIS_OutputVector", cname) == 0) result = LIS_OutputVector;
  if (strcmp("LIS_SolverOutputRHistory", cname) == 0) result = LIS_SolverOutputRHistory;
  if (strcmp("LIS_EsolverOutputRHistory", cname) == 0) result = LIS_EsolverOutputRHistory;

  Dart_ExitScope();
  return result;
}
