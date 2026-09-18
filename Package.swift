// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-cppwinrt",
    products: [
        .library(name: "CppWinRT", targets: ["CppWinRT"])
    ],
    dependencies: [
        .package(url: "https://github.com/rayman-zhao/swift-windowsfoundation", branch: "main"),
        .package(url: "https://github.com/rayman-zhao/swift-cwinrt", branch: "main"),
        .package(url: "https://github.com/rayman-zhao/swift-winui", branch: "main"),
    ],
    targets: [
        .target(
            name: "CppWinRT",
            dependencies: [
                .product(name: "WindowsFoundation", package: "swift-windowsfoundation"),
                .product(name: "WinUI", package: "swift-winui"),
                "CCppWinRT",
            ],
        ),
        .target(
            name: "CCppWinRT",
            dependencies: [],
            exclude: [],
            sources: [
                "./Sources"
            ],
            cxxSettings: [],
        ),
        .testTarget(
            name: "CppWinRTTests",
            dependencies: [
                "CppWinRT",
                .product(name: "CWinRT", package: "swift-cwinrt"),
                .product(name: "WinUI", package: "swift-winui"),
            ],
        ),
    ],
    cxxLanguageStandard: .cxx20
)
