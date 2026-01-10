// Package.swift snippet
.targets: [
    .target(
        name: "HabitApp",
        dependencies: []
    ),
    .testTarget(
        name: "HabitApTests",
        dependencies: ["HabitApp"]
    ),
]
