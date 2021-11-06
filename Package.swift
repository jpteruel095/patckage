// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

struct SPMPackage {
    static let name = "patckage"
    static let platforms: [SupportedPlatform] = [
        .iOS(.v13)
    ]
    static let products = [
        Targets.patckage,
        Targets.patbase,
    ]
    static let targets = [
        Targets.patckage,
        Targets.patbase,
    ]
}

// MARK: Dependency Manager
struct Dependencies {
    // MARK: UI Dependencies
    static let SFSafeSymbols = PackageDependency(
        name: "SFSafeSymbols",
        url: "https://github.com/piknotech/SFSafeSymbols.git",
        fromVersion: "2.1.3")
    
    static let MBProgressHUD = PackageDependency(
        name: "MBProgressHUD",
        url: "https://github.com/jdg/MBProgressHUD.git",
        fromVersion: "1.2.0")
    
    // MARK: Mock Dependencies
    static let Fakery = PackageDependency(
        name: "Fakery",
        url: "https://github.com/vadymmarkov/Fakery.git",
        fromVersion: "5.1.0")
    
    // MARK: Formatting Dependencies
    static let SwiftDate = PackageDependency(
        name: "SwiftDate",
        url: "https://github.com/malcommac/SwiftDate.git",
        fromVersion: "6.3.1")
    
    // MARK: Service Dependencies
    static let SwiftCoroutine = PackageDependency(
        name: "SwiftCoroutine",
        url: "https://github.com/belozierov/SwiftCoroutine.git",
        fromVersion: "2.1.11")
    
    static let Firebase = PackageDependency(
        name: "Firebase",
        url: "https://github.com/firebase/firebase-ios-sdk.git",
        fromVersion: "8.0.0")
    
    enum FirebaseProducts: String, DependencyProduct {
        case Firestore = "FirebaseFirestoreSwift-Beta"
        case FirebaseAuth
    }
    
    // MARK: Unit Test Dependencies
    static let Nimble =  PackageDependency(
        name: "Nimble",
        url: "https://github.com/Quick/Nimble.git",
        fromVersion: "9.2.1")
    
    static let Quick =  PackageDependency(
        name: "Quick",
        url: "https://github.com/Quick/Quick.git",
        fromVersion: "4.0.0")
}

// MARK: Targets Manager
struct Targets {
    private static let commonDependencies = [
        Dependencies.SFSafeSymbols,
        Dependencies.MBProgressHUD,
        Dependencies.Fakery,
        Dependencies.SwiftDate,
        Dependencies.SwiftCoroutine,
    ]
    static let patckage = PackageTarget(
        name: "patckage",
        dependencies: commonDependencies)
    
    static let patbase = PackageTarget(
        name: "patbase",
        dependencies: [
            patckage,
            Dependencies.Firebase.withProducts([
                Dependencies.FirebaseProducts.Firestore
            ]),
        ])
}

// MARK: Type Safe Helpers
protocol AsTargetDependency{
    var targetDependencies:[Target.Dependency] { get }
}

struct PackageDependency: AsTargetDependency, Equatable {
    let name: String
    let dependency: Package.Dependency
    var products: [String] = []
    
    // MARK: Initializers
    init(name: String, url: String, fromVersion version: Version) {
        self.name = name
        self.dependency = .package(name: name,
                                   url: url,
                                   from: version)
    }
    
    init(name: String, url: String, commitId: String) {
        self.name = name
        self.dependency = .package(name: name,
                                   url: url,
                                   .revision(commitId))
    }
    
    init(name: String, url: String, branch: String) {
        self.name = name
        self.dependency = .package(name: name,
                                   url: url,
                                   .branch(branch))
    }
    
    // MARK: Target Dependency-able
    var targetDependencies:[Target.Dependency] {
        if products.isEmpty {
            return [Target.Dependency(stringLiteral: name)]
        }else{
            return self.products.compactMap({ (product) -> Target.Dependency in
                return .product(name: product, package: self.name)
            })
        }
    }
    
    func withProducts<ProductType: DependencyProduct>(_ products: [ProductType]) -> PackageDependency {
        var dependency = self
        dependency.products = products.compactMap({$0.name})
        return dependency
    }
    
    static func == (lhs: PackageDependency, rhs: PackageDependency) -> Bool {
        return lhs.name == rhs.name
    }
}

protocol DependencyProduct {
    var name: String { get }
}

extension DependencyProduct where Self: RawRepresentable, RawValue == String {
    var name: String {
        self.rawValue
    }
}

extension String: DependencyProduct {
    var name: String {
        self
    }
}

struct EmptyProducts: DependencyProduct {
    var name: String = ""
}

struct PackageTarget: AsTargetDependency {
    let name: String
    let target: Target
    let packageDependencies: [PackageDependency]
    
    init(name: String, path: String? = nil, dependencies: [AsTargetDependency], resourcesLocation: String? = nil) {
        self.name = name
        let finalDependencies: [Target.Dependency] = dependencies.compactMap({$0.targetDependencies}).reduce([]) { result, element in
            return result + element
        }
        self.packageDependencies = dependencies.compactMap({
            $0 as? PackageDependency
        })
        self.target = .target(name: name,
                              dependencies: finalDependencies,
                              path: path,
                              resources: resourcesLocation == nil ? nil : [.process(resourcesLocation!)])
    }
    
    init(testName: String, dependencies: [AsTargetDependency]) {
        self.name = testName
        let finalDependencies: [Target.Dependency] = dependencies.compactMap({$0.targetDependencies}).reduce([]) { result, element in
            return result + element
        }
        self.packageDependencies = dependencies.compactMap({
            $0 as? PackageDependency
        })
        self.target = .testTarget(name: testName, dependencies: finalDependencies)
    }
    
    var targetDependencies: [Target.Dependency] {
        return [Target.Dependency(stringLiteral: name)]
    }
    
    var library: Product {
        return .library(name: self.name, targets: [self.name])
    }
}

extension SPMPackage {
    static var dependencies: [PackageDependency] {
        let nested = SPMPackage.targets.compactMap({
            $0.packageDependencies
        })
        return nested.reduce([]) { partialResult, dependencies in
            return partialResult + dependencies.filter({!partialResult.contains($0)})
        }
    }
}
// MARK: Manifest
let package = Package(
    name: SPMPackage.name,
    platforms: SPMPackage.platforms,
    products: SPMPackage.products.compactMap({$0.library}),
    dependencies: SPMPackage.dependencies.compactMap({$0.dependency}),
    targets: SPMPackage.targets.compactMap({$0.target})
)

