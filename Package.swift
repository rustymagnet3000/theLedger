import PackageDescription

let package = Package(
    name: "theLedger",
    dependencies: [
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 0, minor: 18)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)

