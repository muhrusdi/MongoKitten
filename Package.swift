import PackageDescription

var package = Package(
    name: "MongoKitten",
    dependencies: [
        // For MongoCR authentication
        .Package(url: "https://github.com/CryptoKitten/MD5.git", majorVersion: 0, minor: 10),
        
        // For SCRAM-SHA-1 authentication
        .Package(url: "https://github.com/CryptoKitten/SCRAM.git", majorVersion: 0, minor: 10),
        .Package(url: "https://github.com/CryptoKitten/SHA1.git", majorVersion: 0, minor: 10),
        
        // For MongoDB Documents
        .Package(url: "https://github.com/OpenKitten/BSON.git", majorVersion: 3, minor: 5),
        
        // Provides sockets
        .Package(url: "https://github.com/czechboy0/Socks.git", majorVersion: 0, minor: 10),

        // Background queue
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 6),

        ]
)

let lib = Product(name: "MongoKitten", type: .Library(.Dynamic), modules: "MongoKitten")
