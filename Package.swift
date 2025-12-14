// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "Supertone",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Supertone",
            targets: ["Supertone"]
        ),
        .library(
            name: "onnxruntime",
            type: .static,
            targets: ["OnnxRuntimeBindings"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    ],
    targets: [
        // ONNX Runtime binary - hosted on GitHub Releases for Xcode Cloud compatibility
        .binaryTarget(
            name: "onnxruntime",
            url: "https://github.com/j-j-m/supertone-swift/releases/download/v1.0.0-onnx/onnxruntime-c-1.20.0.zip",
            checksum: "50891a8aadd17d4811acb05ed151ba6c394129bb3ab14e843b0fc83a48d450ff"
        ),
        .binaryTarget(
            name: "onnxruntime_extensions",
            url: "https://github.com/j-j-m/supertone-swift/releases/download/v1.0.0-onnx/onnxruntime-extensions-c-0.13.0.zip",
            checksum: "346522d1171d4c99cb0908fa8e4e9330a4a6aad39cd83ce36eb654437b33e6b5"
        ),

        // ONNX Runtime Objective-C++ bindings
        .target(
            name: "OnnxRuntimeBindings",
            dependencies: ["onnxruntime"],
            path: "objectivec",
            exclude: ["ReadMe.md", "format_objc.sh", "test", "docs",
                      "ort_checkpoint.mm",
                      "ort_checkpoint_internal.h",
                      "ort_training_session_internal.h",
                      "ort_training_session.mm",
                      "include/ort_checkpoint.h",
                      "include/ort_training_session.h",
                      "include/onnxruntime_training.h"],
            cxxSettings: [
                .define("SPM_BUILD"),
            ]
        ),

        // ONNX Runtime Extensions
        .target(
            name: "OnnxRuntimeExtensions",
            dependencies: ["onnxruntime_extensions", "onnxruntime"],
            path: "extensions",
            cxxSettings: [
                .define("ORT_SWIFT_PACKAGE_MANAGER_BUILD"),
            ]
        ),

        // Supertone TTS
        .target(
            name: "Supertone",
            dependencies: ["OnnxRuntimeBindings"],
            swiftSettings: swiftSettings
        ),

        .testTarget(
            name: "SupertoneTests",
            dependencies: ["Supertone"],
            swiftSettings: swiftSettings
        ),
    ],
    cxxLanguageStandard: .cxx17
)
