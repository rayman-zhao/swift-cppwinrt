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
