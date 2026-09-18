#pragma once

#include <inspectable.h>

#ifdef __cplusplus
extern "C" {
#endif

IInspectable * single_threaded_vector_inspectable(int count, const wchar_t *start);
IInspectable * single_threaded_observable_vector_inspectable(int count, const wchar_t *start);

#ifdef __cplusplus
}
#endif