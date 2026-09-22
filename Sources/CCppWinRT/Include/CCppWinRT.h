#pragma once

// WinSDK 模块化头：roapi.h 属于 clang module WinSDK.RoApi，会带出 IInspectable；
// winstring.h 提供 HSTRING。不能直接 #include <inspectable.h>（非模块化头，
// Swift 6.4 SDK 下与 WinSDK.RoApi 中的重复包含冲突）。
#include <wtypesbase.h>
#include <minwindef.h>
#include <winnt.h>
#include <combaseapi.h>
#include <roapi.h>
#include <winstring.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

IInspectable * single_threaded_vector_inspectable(int count, const wchar_t *start);
IInspectable * single_threaded_observable_vector_inspectable(int count, const wchar_t *start);

// 解箱单个元素（装箱字符串的运行时类是 IReference`1<String>）。
// 返回 HRESULT（>= 0 成功），成功时 *result 归调用方所有
//（WindowsDeleteString 释放）。

int32_t inspectable_get_string(IInspectable *value, HSTRING *result);

#ifdef __cplusplus
}
#endif
