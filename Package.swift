// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CodableToTypeScript",
    products: [
        .library(
            name: "CodableToTypeScript",
            targets: ["CodableToTypeScript"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/SwiftTypeReader", from: "2.2.0"),
        .package(url: "https://github.com/omochi/TypeScriptAST", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "TestUtils"
        ),
        .target(
            name: "CodableToTypeScript",
            dependencies: [
                .product(name: "SwiftTypeReader", package: "SwiftTypeReader"),
                .product(name: "TypeScriptAST", package: "TypeScriptAST")
            ]
        ),
        .testTarget(
            name: "CodableToTypeScriptTests",
            dependencies: [
                .target(name: "TestUtils"),
                .target(name: "CodableToTypeScript")
            ]
        ),
    ]
)
