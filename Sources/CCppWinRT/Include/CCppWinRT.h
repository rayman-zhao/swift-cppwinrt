#pragma once

#include <inspectable.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

IInspectable * single_threaded_vector_inspectable(int count, const wchar_t *start);
IInspectable * single_threaded_observable_vector_inspectable(int count, const wchar_t *start);

// 读取向量中 index 处的字符串元素（GetAt 与解箱合一）。返回 HRESULT（>= 0 成功），
// 成功时 *result 归调用方所有（WindowsDeleteString 释放）。

int32_t vector_get_string_at(IInspectable *vector, uint32_t index, HSTRING *result);

#ifdef __cplusplus
}
#endif
