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

namespace
{
    // 共享的解箱实现：装箱字符串的规范解法是 unbox_value（非字符串元素抛
    // hresult_no_interface）。
    int32_t unbox_to_hstring(
        winrt::Windows::Foundation::IInspectable const& value, HSTRING *result) noexcept
    {
        constexpr int32_t E_FAIL_ = static_cast<int32_t>(0x80004005);
        try
        {
            auto string = winrt::unbox_value<winrt::hstring>(value);
            if (FAILED(WindowsCreateString(string.c_str(), static_cast<uint32_t>(string.size()), result)))
            {
                return E_FAIL_;
            }
            return 0;
        }
        catch (winrt::hresult_error const& e) { return static_cast<int32_t>(e.code().value); }
        catch (...) { return E_FAIL_; }
    }
}

int32_t inspectable_get_string(::IInspectable *value, HSTRING *result)
{
    constexpr int32_t E_INVALIDARG_ = static_cast<int32_t>(0x80070057);
    if (!value || !result) return E_INVALIDARG_;
    winrt::com_ptr<::IInspectable> ptr;
    ptr.copy_from(value);
    return unbox_to_hstring(ptr.as<winrt::Windows::Foundation::IInspectable>(), result);
}
