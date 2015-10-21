#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include "lis.h"
#include "dart_api.h"

Dart_NativeFunction ResolveName(Dart_Handle name, int argc,
    bool* auto_setup_scope);


DART_EXPORT Dart_Handle lis_extension_Init(Dart_Handle parent_library) {
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


void Dart_GetNativeVectorArgument(Dart_NativeArguments args, int index,
    LIS_VECTOR* value) {
  uint64_t ptr;
  HandleError(Dart_GetNativeUint64Argument(args, index, &ptr));
  *value = (LIS_VECTOR) ptr;
}


void Dart_GetNativeLisIntArgument(Dart_NativeArguments args, int index,
    LIS_INT* value) {
  int64_t v;
  HandleError(Dart_GetNativeIntegerArgument(args, index, &v));
  *value = (LIS_INT) v;
}


void Dart_GetNativeLisScalarArgument(Dart_NativeArguments args, int index,
    LIS_SCALAR* value) {
  double v;
  HandleError(Dart_GetNativeDoubleArgument(args, index, &v));
  *value = (LIS_SCALAR) v;
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
  if (Dart_IsTypedData(obj)) {
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
        HandleError(Dart_IntegerFitsIntoInt64(obj, &fits));
        if (fits) {
          HandleError(Dart_IntegerToInt64(obj, &val2));
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
  Dart_TypedData_Type type;
  void* data;
  intptr_t len, i;
  double* dataP;
  double val2;

  obj = HandleError(Dart_GetNativeArgument(args, index));
  if (Dart_IsTypedData(obj)) {
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
  } else if (Dart_IsList(obj)) {
	HandleError(Dart_ListLength(obj, &len));
	*value = (LIS_SCALAR*) malloc(sizeof(LIS_SCALAR) * len);
	for (i = 0; i < len; i++) {
	  val = HandleError(Dart_ListGetAt(obj, i));
	  if (Dart_IsDouble(val)) {
        HandleError(Dart_DoubleValue(val, &val2));
		(*value)[i] = (LIS_SCALAR) val2;
      } else {
        HandleError(Dart_NewApiError("expected List<S>"));
	  }
	}
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
  err = lis_initialize(&argc, &p_argv)
		  ; CHKERR(err);
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

  Dart_SetDoubleReturnValue(arguments, value);
  Dart_ExitScope();
}


void LIS_VectorGetValues(Dart_NativeArguments arguments) {
  LIS_INT err, start, count;
  LIS_VECTOR vec;
  Dart_Handle result;
  LIS_SCALAR *value;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);
  Dart_GetNativeLisIntArgument(arguments, 2, &start);
  Dart_GetNativeLisIntArgument(arguments, 3, &count);

  value = (LIS_SCALAR *) malloc(sizeof(LIS_SCALAR) * count);

  err = lis_vector_get_values(vec, start, count, value); CHKERR(err);

  result = Dart_NewExternalTypedData(Dart_TypedData_kFloat64, value,
    (intptr_t) count);

  Dart_SetReturnValue(arguments, HandleError(result));
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

  Dart_SetIntegerReturnValue(arguments, retval);
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

  Dart_SetDoubleReturnValue(arguments, value);
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

  Dart_SetDoubleReturnValue(arguments, value);
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

  Dart_ExitScope();
  return result;
}
