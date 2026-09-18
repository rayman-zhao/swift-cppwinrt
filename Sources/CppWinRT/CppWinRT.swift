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

    /// index 处的字符串元素；越界或非字符串元素返回 nil
    ///（越界经 GetAt 抛 E_BOUNDS 自然失败）。解箱经 `boxedString`。
    public func string(at index: Int) -> String? {
        guard let value = try? GetAt(UInt32(index)) else { return nil }
        return (value as? String) ?? (value as? WindowsFoundation.IInspectable)?.boxedString
    }
}

extension WindowsFoundation.IVectorView where T == Any? {

    /// index 处的字符串元素（如 ItemsView 的 `selectedItems` 视图）；
    /// 越界或非字符串元素返回 nil。与 `IVectorAny.string(at:)` 同名同义。
    /// 注：协议一致性的 getAt 内部为 try!，越界会致命崩溃，须先按 count 预检。
    public func string(at index: Int) -> String? {
        guard index >= 0, index < count else { return nil }
        guard let value = getAt(UInt32(index)) else { return nil }
        return (value as? String) ?? (value as? WindowsFoundation.IInspectable)?.boxedString
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
    _ value: WindowsFoundation.IInspectable
) -> UnsafeMutablePointer<CCppWinRT.IInspectable>! {
    UnsafeMutableRawPointer(value.pUnk.borrow)
        .assumingMemoryBound(to: CCppWinRT.IInspectable.self)
}
