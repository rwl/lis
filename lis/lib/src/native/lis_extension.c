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

Dart_Handle Dart_GetNativeUint64Argument(Dart_NativeArguments args,
                                                      int index,
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

void LIS_Initialize(Dart_NativeArguments arguments) {
  LIS_INT err, argc;
  char* argv[] = { "lis", NULL };
  char** p_argv;

  Dart_EnterScope();
  argc = 1;
  p_argv = &argv[0];
  err = lis_initialize(&argc, &p_argv); CHKERR(err);
//	err = lis_initialize(0, NULL);
  Dart_ExitScope();
}

void LIS_Finalize(Dart_NativeArguments arguments) {
  LIS_INT err;
  Dart_EnterScope();
  err = lis_finalize(); CHKERR(err);
  Dart_ExitScope();
}

void LIS_VectorCreate(Dart_NativeArguments arguments) {
  Dart_Handle result;
  LIS_INT err;
  LIS_VECTOR vec;

  Dart_EnterScope();
  err = lis_vector_create(LIS_COMM_WORLD, &vec); CHKERR(err);
  result = HandleError(Dart_NewIntegerFromUint64((uint64_t) vec));

//  printf("vec: %" PRIu64 "\n", (uint64_t) vec);

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}


void LIS_VectorSetSize(Dart_NativeArguments arguments) {
  Dart_Handle result;
  LIS_INT err;
  LIS_VECTOR vec;
  LIS_INT n;
//  bool fits;
  uint64_t p_vec, N;
//  Dart_Handle vec_object, n_object;

  Dart_EnterScope();

  HandleError(Dart_GetNativeUint64Argument(arguments, 1, &p_vec));
//  printf("p_vec: %" PRIu64 "\n", p_vec);
  vec = (LIS_VECTOR) p_vec;

  HandleError(Dart_GetNativeUint64Argument(arguments, 2, &N));
  n = (LIS_INT) N;

//  vec_object = HandleError(Dart_GetNativeArgument(arguments, 1));
//
//  if (Dart_IsInteger(vec_object)) {
//    HandleError(Dart_IntegerFitsIntoUint64(vec_object, &fits));
//    if (fits) {
//      HandleError(Dart_IntegerToUint64(vec_object, &p_vec));
//      vec = (LIS_VECTOR) p_vec;
//      printf("p_vec: %" PRIu64 "\n", p_vec);
//    }
//  }
//
//  n_object = HandleError(Dart_GetNativeArgument(arguments, 2));
//  if (Dart_IsInteger(n_object)) {
//    HandleError(Dart_IntegerFitsIntoUint64(n_object, &fits));
//    if (fits) {
//      HandleError(Dart_IntegerToUint64(n_object, &n64));
//      n = (LIS_INT) n64;
//      printf("n64: %" PRIu64 "\n", n64);
//    }
//  }
//  printf("n: %d\n", n);

  err = lis_vector_set_size(vec, n, n); CHKERR(err);
  result = HandleError(Dart_Null());

  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

void LIS_VectorSetAll(Dart_NativeArguments arguments) {
  LIS_INT err;
  uint64_t vec;
  LIS_SCALAR alpha;

  Dart_EnterScope();
  HandleError(Dart_GetNativeDoubleArgument(arguments, 1, &alpha));
  HandleError(Dart_GetNativeUint64Argument(arguments, 2, &vec));

  err = lis_vector_set_all(alpha, (LIS_VECTOR) vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}

void LIS_VectorPrint(Dart_NativeArguments arguments) {
  LIS_INT err;
  uint64_t vec;

  Dart_EnterScope();
  HandleError(Dart_GetNativeUint64Argument(arguments, 1, &vec));

  err = lis_vector_print((LIS_VECTOR) vec); CHKERR(err);

  Dart_SetReturnValue(arguments, HandleError(Dart_Null()));
  Dart_ExitScope();
}

void LIS_VectorDestroy(Dart_NativeArguments arguments) {
  LIS_INT err;
  uint64_t vec;

  Dart_EnterScope();
  HandleError(Dart_GetNativeUint64Argument(arguments, 1, &vec));

  err = lis_vector_destroy((LIS_VECTOR) vec); CHKERR(err);

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

  Dart_ExitScope();
  return result;
}
