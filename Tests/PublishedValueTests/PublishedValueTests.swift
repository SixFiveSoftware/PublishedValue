import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PublishedValueMacros)
import PublishedValueMacros

let testMacros: [String: Macro.Type] = [
    "PublishedValue": PublishedValueMacro.self,
]
#endif

final class PublishedValueTests: XCTestCase {
    func testMacro() throws {
        #if canImport(PublishedValueMacros)
        assertMacroExpansion(
            """
            @PublishedValue(of: Int.self, named: "value")
            class Foo {
            }
            """,
            expandedSource: """
            class Foo {

                @Published private (set) var value: Int

                var valuePublisher: Published<Int> .Publisher {
                    $value
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testProtocolMacro() throws {
        #if canImport(PublishedValueMacros)
        assertMacroExpansion(
            """
            @PublishedValue(of: Int.self, named: "value")
            protocol FooProtocol {
            }
            """,
            expandedSource: """
            protocol FooProtocol {

                var value: Int {
                    get
                }

                var valuePublisher: Published<Int> .Publisher {
                    get
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
