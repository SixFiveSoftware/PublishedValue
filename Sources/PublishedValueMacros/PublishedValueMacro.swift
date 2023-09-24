import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum PublishedValueError: Error {
    case mustHaveTwoArguments(provided: Int)
    case mustBeClassActorOrProtocol
}

public struct PublishedValueMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        try Self.validate(context: declaration)
        let arguments = try Self.arguments(from: node)
        let type = try Self.type(from: arguments[0])
        let name = try Self.name(from: arguments[1])
        return try syntax(forContext: declaration, type: type, name: name)
    }
}

extension PublishedValueMacro {
    static private func syntax(forContext context: DeclGroupSyntax, type: ExprSyntax, name: String) throws -> [SwiftSyntax.DeclSyntax] {
        if context.is(ClassDeclSyntax.self) || context.is(ActorDeclSyntax.self) {
            return [
                "@Published private(set) var \(raw: name): \(raw: type)",
                "var \(raw: name)Publisher: Published<\(raw: type)>.Publisher { $\(raw: name) }"
            ]
        } else {
            return [
                "var \(raw: name): \(raw: type) { get }",
                "var \(raw: name)Publisher: Published<\(raw: type)>.Publisher { get }"
            ]
        }
    }

    static private func validate(context: some DeclGroupSyntax) throws {
        guard context.is(ClassDeclSyntax.self) || context.is(ActorDeclSyntax.self) || context.is(ProtocolDeclSyntax.self) else {
            throw PublishedValueError.mustBeClassActorOrProtocol
        }
    }

    static private func arguments(from node: AttributeSyntax) throws -> [LabeledExprSyntax] {
        guard case .argumentList(let argumentList) = node.arguments else { throw PublishedValueError.mustHaveTwoArguments(provided: 0) }
        let arguments = argumentList
            .children(viewMode: .sourceAccurate)
            .compactMap { $0.as(LabeledExprSyntax.self) }
        guard arguments.count == 2 else { throw PublishedValueError.mustHaveTwoArguments(provided: arguments.count) }
        return arguments
    }

    static private func type(from attribute: LabeledExprSyntax) throws -> ExprSyntax {
        guard let type = attribute
            .expression
            .as(MemberAccessExprSyntax.self)?
            .base else { fatalError("The first argument should be a type") }
        return type
    }

    static private func name(from attribute: LabeledExprSyntax) throws -> String {
        guard let name = attribute
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue else { fatalError("The second argument should be a String") }
        return name
    }
}

@main
struct PublishedValuePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PublishedValueMacro.self,
    ]
}
