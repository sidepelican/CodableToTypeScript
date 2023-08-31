import SwiftTypeReader
import TypeScriptAST

struct RawRepresentableConverter: TypeConverter {
    init(
        generator: CodeGenerator,
        swiftType: any SType,
        rawValueType raw: any SType
    ) throws {
        let map = swiftType.contextSubstitutionMap()
        let raw = raw.subst(map: map)

        self.generator = generator
        self.swiftType = swiftType
        self.rawValueType = try generator.converter(for: raw)
    }

    var generator: CodeGenerator
    var swiftType: any SType
    var rawValueType: any TypeConverter

    func type(for target: GenerationTarget) throws -> any TSType {
        if case .json = target, rawValueType.swiftType.isRawRepresentableCodingType() {
            return try generator.converter(for: rawValueType.swiftType).type(for: target)
        }

        return try `default`.type(for: target)
    }

    func typeDecl(for target: GenerationTarget) throws -> TSTypeDecl? {
        let name = try self.name(for: target)
        let genericParams: [TSTypeParameterNode] = try self.genericParams().map {
            .init(try $0.name(for: target))
        }
        switch target {
        case .entity:
            let fieldType = try rawValueType.fieldType(for: .entity)

            let field: TSObjectType.Field = .field(
                name: "rawValue", isOptional: fieldType.isOptional, type: fieldType.type
            )

            var type: any TSType = TSObjectType([field])

            let tag = try generator.tagRecord(
                name: name,
                genericArgs: try self.genericParams().map { (param) in
                    TSIdentType(try param.name(for: .entity))
                }
            )

            type = TSIntersectionType(type, tag)

            return TSTypeDecl(
                modifiers: [.export],
                name: name,
                genericParams: genericParams,
                type: type
            )
        case .json:
            return TSTypeDecl(
                modifiers: [.export],
                name: name,
                genericParams: genericParams,
                type: try rawValueType.type(for: target)
            )
        }
    }

    func decodePresence() throws -> CodecPresence {
        return .required
    }

    func decodeDecl() throws -> TSFunctionDecl? {
        guard let decl = try decodeSignature() else { return nil }

        let value = try rawValueType.callDecode(json: TSIdentExpr.json)
        let field = try rawValueType.valueToField(value: value, for: .entity)

        let object = TSObjectExpr([
            .named(name: "rawValue", value: field)
        ])

        decl.body.elements.append(
            TSReturnStmt(object)
        )

        return decl
    }

    func callDecode(json: any TSExpr) throws -> any TSExpr {
        if rawValueType.swiftType.isRawRepresentableCodingType() {
            let value = try rawValueType.callDecodeField(json: json)
            let field = try rawValueType.valueToField(value: value, for: .entity)
            return TSObjectExpr([
                .named(name: "rawValue", value: field)
            ])
        }
        return try `default`.callDecode(json: json)
    }

    func encodePresence() throws -> CodecPresence {
        return .required
    }

    func encodeDecl() throws -> TSFunctionDecl? {
        guard let decl = try encodeSignature() else { return nil }

        let field = try rawValueType.callEncodeField(
            entity: TSMemberExpr(base: TSIdentExpr.entity, name: "rawValue")
        )
        let value = try rawValueType.fieldToValue(field: field, for: .json)

        decl.body.elements.append(
            TSReturnStmt(value)
        )

        return decl
    }

    func callEncode(entity: any TSExpr) throws -> TSExpr {
        if rawValueType.swiftType.isRawRepresentableCodingType() {
            let field = try rawValueType.callEncodeField(
                entity: TSMemberExpr(base: entity, name: "rawValue")
            )
            let value = try rawValueType.fieldToValue(field: field, for: .json)
            return value
        }
        return try `default`.callEncode(entity: entity)
    }
}
