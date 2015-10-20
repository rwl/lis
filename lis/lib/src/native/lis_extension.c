#include <string.h>

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

void LIS_Initialize(Dart_NativeArguments arguments) {
	LIS_INT err;
  Dart_EnterScope();
//	err = lis_initialize(LIS_INT *argc, char** argv[]);
  Dart_ExitScope();
}

void LIS_VectorCreate(Dart_NativeArguments arguments) {
  Dart_Handle result;
  LIS_INT err;
  LIS_VECTOR vec;
//  LIS_INT lis_vector_create(LIS_Comm comm, LIS_VECTOR *vec);

  Dart_EnterScope();
  err = lis_vector_create(LIS_COMM_WORLD, &vec);
//  result = HandleError(Dart_NewInteger(rand()));
  Dart_SetReturnValue(arguments, result);
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
  if (strcmp("LIS_VectorCreate", cname) == 0) result = LIS_VectorCreate;

  Dart_ExitScope();
  return result;
}
