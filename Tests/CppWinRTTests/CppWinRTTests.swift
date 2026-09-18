import CWinRT
import CppWinRT
import Testing
import WindowsFoundation
import WinUI

/// 可观察向量链路验证：工厂创建 → 类型化句柄原地增删 → VectorChanged 通知
/// 逐次触发 → 退订后静默。
@Suite struct ObservableVectorTests {

    @Test func mutationsFireVectorChanged() throws {
        // box_value 走 PropertyValue 激活工厂，本线程需先初始化 WinRT apartment
        //（RoInitialize 经 CWinRT 模块直接可用；线程已有 apartment 时返回
        // RPC_E_CHANGED_MODE，属可接受）。
        let hr = RoInitialize(RO_INIT_MULTITHREADED)
        #expect(hr >= 0 || hr == Int32(bitPattern: 0x80010106))

        let vector = try #require(single_threaded_observable_vector(["a", "b"]))
        #expect(try vector.get_Size() == 2)
        // 装箱字符串读回：GetAt + 解箱合一。
        #expect(vector.string(at: 0) == "a")
        #expect(vector.string(at: 1) == "b")
        #expect(vector.string(at: 2) == nil)

        let observable: WinUI.IObservableVectorAny = try vector.QueryInterface()
        var changeCount = 0
        let token = try observable.add_VectorChanged { _, _ in
            changeCount += 1
        }

        try vector.Append("c")
        #expect(try vector.get_Size() == 3)

        try vector.InsertAt(0, "z")
        #expect(try vector.get_Size() == 4)

        try vector.RemoveAtEnd()
        #expect(try vector.get_Size() == 3)

        try vector.RemoveAt(1)
        #expect(try vector.get_Size() == 2)

        try vector.Clear()
        #expect(try vector.get_Size() == 0)

        for value in ["1", "2", "3"] {
            try vector.Append(value)
        }
        #expect(try vector.get_Size() == 3)

        // 5 次单点变更（append/insert/removeAtEnd/removeAt/clear）+ 3 次追加，各通知一次。
        #expect(changeCount == 8)

        // 退订后不再通知。
        try observable.remove_VectorChanged(token)
        try vector.Append("4")
        #expect(try vector.get_Size() == 4)
        #expect(changeCount == 8)
    }
}
