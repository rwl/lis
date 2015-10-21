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

void LIS_VectorDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_destroy(vec); CHKERR(err);

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


void LIS_VectorPrint(Dart_NativeArguments arguments) {
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  Dart_GetNativeVectorArgument(arguments, 1, &vec);

  err = lis_vector_print(vec); CHKERR(err);

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
  if (strcmp("LIS_VectorSetAll", cname) == 0) result = LIS_VectorSetAll;
  if (strcmp("LIS_VectorPrint", cname) == 0) result = LIS_VectorPrint;
  if (strcmp("LIS_VectorDestroy", cname) == 0) result = LIS_VectorDestroy;
  if (strcmp("LIS_VectorDuplicate", cname) == 0) result = LIS_VectorDuplicate;
  if (strcmp("LIS_VectorGetSize", cname) == 0) result = LIS_VectorGetSize;
  if (strcmp("LIS_VectorGetValue", cname) == 0) result = LIS_VectorGetValue;
  if (strcmp("LIS_VectorGetValues", cname) == 0) result = LIS_VectorGetValues;
  if (strcmp("LIS_VectorSetValue", cname) == 0) result = LIS_VectorSetValue;

  Dart_ExitScope();
  return result;
}
