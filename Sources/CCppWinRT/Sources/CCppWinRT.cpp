#include "../Include/CCppWinRT.h"
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>

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
