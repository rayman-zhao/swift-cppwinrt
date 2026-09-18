#include "../Include/CCppWinRT.h"
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winstring.h>

using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::Foundation::Collections;

::IInspectable * single_threaded_vector_inspectable(int count, const wchar_t *start)
{
    auto vi = winrt::single_threaded_vector<winrt::Windows::Foundation::IInspectable>();

    for (int i = 0; i < count; ++i)
    {
        start += wcslen(start) + 1;
        vi.Append(winrt::box_value(start));
    }

    auto iinsp = vi.as<::IInspectable>();
    auto *iinsp_ptr = iinsp.get();
    iinsp_ptr->AddRef();
    return iinsp_ptr;
}

::IInspectable * single_threaded_observable_vector_inspectable(int count, const wchar_t *start)
{
    auto vi = winrt::single_threaded_observable_vector<winrt::Windows::Foundation::IInspectable>();

    for (int i = 0; i < count; ++i)
    {
        start += wcslen(start) + 1;
        vi.Append(winrt::box_value(start));
    }

    auto iinsp = vi.as<::IInspectable>();
    auto *iinsp_ptr = iinsp.get();
    iinsp_ptr->AddRef();
    return iinsp_ptr;
}

int32_t vector_get_string_at(::IInspectable *vector, uint32_t index, HSTRING *result)
{
    constexpr int32_t E_INVALIDARG_ = static_cast<int32_t>(0x80070057);
    constexpr int32_t E_FAIL_ = static_cast<int32_t>(0x80004005);
    if (!vector || !result) return E_INVALIDARG_;
    try
    {
        winrt::com_ptr<::IInspectable> ptr;
        ptr.copy_from(vector);
        auto vec = ptr.as<winrt::Windows::Foundation::Collections::IVector<winrt::Windows::Foundation::IInspectable>>();
        // 装箱字符串的规范解法：unbox_value（内部即 IReference<hstring> 取值；
        // 非字符串元素抛 hresult_no_interface，由下方 catch 转 HRESULT）。
        auto value = winrt::unbox_value<winrt::hstring>(vec.GetAt(index));
        if (FAILED(WindowsCreateString(value.c_str(), static_cast<uint32_t>(value.size()), result)))
        {
            return E_FAIL_;
        }
        return 0;
    }
    catch (winrt::hresult_error const& e) { return static_cast<int32_t>(e.code().value); }
    catch (...) { return E_FAIL_; }
}
