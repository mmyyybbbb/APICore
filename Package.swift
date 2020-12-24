// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "APICore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "APICore", targets: ["APICore"])
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "14.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "5.1.0"))
        
    ],
    targets: [
        .target(
            name: "APICore",
            dependencies: ["Moya", "RxSwift"],
            path: "APICore" // Необходим чтобы не переделывать пути на Source
        )
    ]
)
