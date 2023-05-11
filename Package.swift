// swift-tools-version: 5.8
//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2022 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

import PackageDescription

//*============================================================================*
// MARK: * Numberick
//*============================================================================*

let package = Package(
    name: "Numberick",
    platforms: [
        .iOS("16.4"),
        .macCatalyst("16.4"),
        .macOS("13.3"),
        .tvOS("16.4"),
        .watchOS("9.4"),
    ],
    products: [
        //=--------------------------------------=
        // Numberick
        //=--------------------------------------=
        .library(
        name: "Numberick",
        targets: ["Numberick"]),
    ],
    targets: [
        //=--------------------------------------=
        // Numberick
        //=--------------------------------------=
        .target(
        name: "Numberick",
        dependencies: []),
        
        .testTarget(
        name: "NumberickBenchmarks",
        dependencies: ["Numberick"]),
        
        .testTarget(
        name: "NumberickTests",
        dependencies: ["Numberick"]),
    ]
)