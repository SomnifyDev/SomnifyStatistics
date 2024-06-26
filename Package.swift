// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    // MARK: - Name

    name: "SomnifyStatistics",

    // MARK: - Platforms

    platforms: [
        .iOS(.v15)
    ],

    // MARK: - Products

    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SomnifyStatistics",
            targets: [
                "SleepStatistics",
                "WorkoutStatistics",
                "HeartIndicator"
            ]
        ),
    ],

    // MARK: - Dependencies

    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            name: "SomnifyDependencies",
            url: "https://github.com/Somnify/SomnifyDependencies.git",
            .branch("dev")
        ),
        .package(
            name: "HealthCore",
            url: "https://github.com/Somnify/HealthCore.git",
            .branch("dev")
        )
    ],

    // MARK: - Targets

    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HeartIndicator",
            dependencies: [
                .product(name: "HealthCore", package: "HealthCore"),
                .product(name: "SomnifyDependencies", package: "SomnifyDependencies")
            ]
        ),
        .target(
            name: "SleepStatistics",
            dependencies: [
                .product(name: "HealthCore", package: "HealthCore"),
            ]
        ),
        .target(
            name: "WorkoutStatistics",
            dependencies: [
                .product(name: "HealthCore", package: "HealthCore"),
                .product(name: "SomnifyDependencies", package: "SomnifyDependencies")
            ]
        )
    ]

)
