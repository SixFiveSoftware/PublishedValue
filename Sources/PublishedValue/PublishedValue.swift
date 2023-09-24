// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces a value and a Published.Publisher for the value
///
///     @PublishedValue(of: Int.self, named: "value")
///     class Foo {}
///
/// produces the expanded type:
///
///     class Foo {
///         @Published private(set) var value: Int
///         var valuePublisher: Published<Int>.Publisher { $value }
///     }
///
/// Requires `import Combine`.
///
/// Additionally, this macro can be used on a Protocol definition:
///
///     @PublishedValue(of: String.self, named: "name")
///     protocol NameRepositoryProtocol {}
///
/// produces the expanded protocol definition:
///
///     protocol NameRepositoryProtocol {
///         var name: String { get }
///         var namePublisher: Published<String>.Publisher { get }
///     }
///

@attached(member, names: arbitrary)
public macro PublishedValue<T>(of type: T.Type, named: String) = #externalMacro(module: "PublishedValueMacros", type: "PublishedValueMacro")
