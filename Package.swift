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
            url: "https://github.com/j-j-m/supertone-swift/releases/download/v1.0.1-onnx/onnxruntime-c-1.20.0.zip",
            checksum: "bb4ef09277e40d68076fbc71da69048c6a1015e283a61ddde3d1ab759cd91dfb"
        ),
        .binaryTarget(
            name: "onnxruntime_extensions",
            url: "https://github.com/j-j-m/supertone-swift/releases/download/v1.0.1-onnx/onnxruntime-extensions-c-0.13.0.zip",
            checksum: "164bb004bd2e2df73250f23aa1b0871efe69b3113874c0115b8497c3dc8aa4ea"
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
