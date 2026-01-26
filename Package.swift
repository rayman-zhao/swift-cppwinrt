// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-cppwinrt",
    products: [
        .library(name: "CppWinRT", targets: ["CppWinRT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rayman-zhao/swift-windowsfoundation", branch: "main"),
    ],
    targets: [
        .target(
            name: "CppWinRT",
            dependencies: [
                .product(name: "WindowsFoundation", package: "swift-windowsfoundation"),
                "CCppWinRT",
            ],
        ),
        .target(
            name: "CCppWinRT",
            dependencies: [
            ],
            exclude: [
            ],
            sources: [
                "./Sources"
            ],
            cxxSettings: [
            ],
        ),
    ],
    cxxLanguageStandard: .cxx20
)
