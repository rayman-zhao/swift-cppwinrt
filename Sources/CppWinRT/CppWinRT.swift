import WindowsFoundation
import CCppWinRT

public func single_threaded_vector_inspectable(_ items: [String]) -> WindowsFoundation.IInspectable? {
    let comPtr = ComPtrs.initialize { abi in
        let joined = items.reduce(into: [UInt16(0)]) { $0 += ($1.utf16 + [0]) }
        abi = single_threaded_vector_inspectable(Int32(items.count), joined)
    }
    guard let comPtr else { return nil }

    return WindowsFoundation.IInspectable(comPtr)
}
