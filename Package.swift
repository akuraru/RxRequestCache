// swift-tools-version:5.1
import PackageDescription

let buildTests = false

let package = Package(
  name: "RxRequestCache",
  products: ([
      .library(name: "RxRequestCache", targets: ["RxRequestCache"]),
  ],
  targets: ([
      .target(name: "RxRequestCache", dependencies: []),
  ],
  swiftLanguageVersions: [.v5]
)
