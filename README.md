# PInject

A lightweight, thread-safe dependency injection framework for **Swift** and **SwiftUI** powered by the `@Inject` property wrapper and a centralized `PIContainer`.

`PInject` is distributed as a pre-compiled binary XCFramework supporting **iOS** (Device & Simulator) and **macOS**.

---

## Features

- **Ergonomic Property Wrapper**: Use `@Inject` to inject dependencies directly into properties without boilerplate.
- **High-Performance O(1) Lookup**: Utilizes native `ObjectIdentifier` for zero-allocation, thread-safe dependency resolution.
- **Flexible Lifetimes**: Supports singleton instances as well as transient factory scopes (`register(_:factory:)`).
- **Thread-Safe Container**: Protected by `NSRecursiveLock` to allow safe concurrent registration and resolution.
- **Protocol & Concrete Support**: Register concrete implementations or abstract protocol types (e.g. `(any NetworkService).self`).
- **MainActor Compatible**: Fully compatible with modern Swift concurrency and `@MainActor`.
- **Test-Friendly**: Easily override registrations, create isolated `PIContainer()` instances, or reset container state between unit tests.
- **Pre-compiled Binary Distribution**: Ready to use as an SPM binary target without compiling source code.

---

## Requirements

| Platform | Minimum Version | Architectures |
| :--- | :--- | :--- |
| **iOS** | 12.0+ (iOS 13+ for Concurrency / `@MainActor`) | `arm64` (Device) & `arm64`, `x86_64` (Simulator) |
| **macOS** | 10.13+ (macOS 10.15+ for Concurrency / `@MainActor`) | `arm64`, `x86_64` (Universal) |
| **Swift** | 5.9+ (Swift 6 compatible) | - |
| **Xcode** | 15.0+ | - |

---

## Installation

### Swift Package Manager (SPM)

#### Option 1: Via `Package.swift`

Add `PInject` to your dependencies in `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyApplication",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/rahmat3nanda/PInject.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyApplication",
            dependencies: [
                .product(name: "PInject", package: "PInject")
            ]
        )
    ]
)
```

#### Option 2: Via Xcode

1. Open your project in Xcode.
2. Navigate to **File** > **Add Package Dependencies...**
3. Paste the repository URL: `https://github.com/rahmat3nanda/PInject.git`
4. Set the dependency rule (e.g. `Up to Next Major Version` from `1.0.0`).
5. Choose your target and click **Add Package**.

---

## Quick Start Guide

### 1. Define Services & Protocols

```swift
import Foundation

public protocol NetworkService: AnyObject {
    func request(endpoint: String) -> String
}

public final class DefaultNetworkService: NetworkService {
    public init() {}
    public func request(endpoint: String) -> String {
        return "response from \(endpoint)"
    }
}
```

---

### 2. Register Dependencies

Register dependencies at app startup (e.g. in your `App` or `AppDelegate`):

```swift
import PInject

@MainActor
func setupDependencies() {
    let container = PIContainer.shared

    // Register by protocol (singleton):
    container.register(
        (any NetworkService).self,
        dependency: DefaultNetworkService()
    )

    // Register by concrete type (singleton):
    container.register(
        DefaultNetworkService.self,
        dependency: DefaultNetworkService()
    )

    // Register factory closure (transient - creates a fresh instance per resolution):
    container.register(HomeViewModel.self) {
        HomeViewModel()
    }
}
```

---

### 3. Resolve Dependencies with `@Inject`

Inject dependencies into your classes or view models:

```swift
import SwiftUI
import PInject

@MainActor
final class HomeViewModel: ObservableObject {
    @Inject private var networkService: any NetworkService

    func loadData() {
        let result = networkService.request(endpoint: "/dashboard")
        print(result)
    }
}
```

You can also resolve dependencies programmatically without the property wrapper:

```swift
let service = PIContainer.shared.resolve((any NetworkService).self)
```

---

### 4. Unit Testing with Mock Services

Easily substitute mock doubles during unit testing and reset container state between tests:

```swift
import Testing
@testable import MyApplication
import PInject

final class MockNetworkService: NetworkService {
    func request(endpoint: String) -> String {
        return "mock_response"
    }
}

@Suite("Feature Tests")
struct FeatureTests {
    @Test func testFeature() async throws {
        await MainActor.run {
            let container = PIContainer.shared
            container.reset() // Reset container state

            // Register mock service
            container.register((any NetworkService).self, dependency: MockNetworkService())

            let vm = HomeViewModel()
            vm.loadData()
        }
    }
}
```

---

## Example Application

Check out the interactive SwiftUI showcase app for iOS and macOS demonstrating real-world usage, protocol-based `@Inject`, transient scopes, and runtime dependency swapping:

👉 [**PInject-Example Repository**](https://github.com/rahmat3nanda/PInject-Example.git)

---

## API Reference

| Method / Property | Description |
| :--- | :--- |
| `PIContainer.shared` | The shared singleton instance of the dependency container. |
| `PIContainer()` | Initializes an independent, isolated container for tests or feature scoping. |
| `container.register(type, dependency:)` | Registers a singleton dependency instance for the specified type or protocol. |
| `container.register(type, factory:)` | Registers a factory closure producing a fresh instance on each resolution (transient scope). |
| `container.resolve(type)` | Resolves and returns the registered dependency cast to `T`. |
| `container.isRegistered(type)` | Checks whether a dependency or factory is currently registered for the given type. |
| `container.unregister(type)` | Removes the dependency registration or factory for the specified type. |
| `container.reset()` | Clears all registered dependencies and factories from the container. |
| `@Inject` | Property wrapper that automatically resolves the dependency on access. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
