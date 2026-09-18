import CCppWinRT
import WinUI
import WindowsFoundation

public func single_threaded_vector_inspectable(_ items: [String]) -> WindowsFoundation.IInspectable? {
    let comPtr = ComPtrs.initialize { abi in
        let joined = items.reduce(into: [UInt16(0)]) { $0 += ($1.utf16 + [0]) }
        abi = single_threaded_vector_inspectable(Int32(items.count), joined)
    }
    guard let comPtr else { return nil }

    return WindowsFoundation.IInspectable(comPtr)
}

public func single_threaded_observable_vector_inspectable(_ items: [String]) -> WindowsFoundation.IInspectable? {
    let comPtr = ComPtrs.initialize { abi in
        let joined = items.reduce(into: [UInt16(0)]) { $0 += ($1.utf16 + [0]) }
        abi = single_threaded_observable_vector_inspectable(Int32(items.count), joined)
    }
    guard let comPtr else { return nil }

    return WindowsFoundation.IInspectable(comPtr)
}

/// 创建单线程可观察向量并直接给出类型化句柄：`Append` / `InsertAt` / `RemoveAt`
/// 等原地增删会发出原生 `VectorChanged`（`IObservableVectorAny.add_VectorChanged`
/// 可订阅）。调用线程需已初始化 WinRT apartment（经 `import CWinRT` 直接调用
/// `RoInitialize` 即可）。
public func single_threaded_observable_vector(_ items: [String]) -> WinUI.IVectorAny? {
    guard let source = single_threaded_observable_vector_inspectable(items) else { return nil }
    return try? source.QueryInterface()
}

extension WinUI.IVectorAny {

    /// index 处的字符串元素。GetAt 与解箱在原生侧一次往返完成（装箱字符串的
    /// 运行时类是 `IReference`1<String>`，投影的 Any 解包不认它）；越界或
    /// 非字符串元素返回 nil。
    public func string(at index: Int) -> String? {
        var hstring: HSTRING?
        guard vector_get_string_at(rawInspectable(self), UInt32(index), &hstring) >= 0,
            let hstring
        else { return nil }
        return String(hString: HString(consuming: hstring))
    }
}

extension WindowsFoundation.IInspectable {

    /// 装箱字符串内容。经 `unbox_value<hstring>` 原生解箱（同
    /// `IVectorAny.string(at:)` 的理由，投影的 Any 解包不认 IReference`1<String>）；
    /// 非字符串返回 nil。适合从 `Any?` 里取出 WinRT 集合（如 ItemsView 的
    /// `selectedItems`）中的字符串元素。
    public var boxedString: String? {
        var hstring: HSTRING?
        guard inspectable_get_string(rawInspectable(self), &hstring) >= 0,
            let hstring
        else { return nil }
        return String(hString: HString(consuming: hstring))
    }
}

private func rawInspectable(
    _ vector: WinUI.IVectorAny
) -> UnsafeMutablePointer<CCppWinRT.IInspectable>! {
    UnsafeMutableRawPointer(vector.pUnk.borrow)
        .assumingMemoryBound(to: CCppWinRT.IInspectable.self)
}

private func rawInspectable(
    _ value: WindowsFoundation.IInspectable
) -> UnsafeMutablePointer<CCppWinRT.IInspectable>! {
    UnsafeMutableRawPointer(value.pUnk.borrow)
        .assumingMemoryBound(to: CCppWinRT.IInspectable.self)
}
