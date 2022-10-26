import SwiftTypeReader
import TSCodeModule
import XCTest
@testable import CodableToTypeScript

enum Utils {
    static func generate(
        source: String,
        typeMap: TypeMap? = nil,
        typeSelector: TypeSelector,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TSCode {
        let result = try Reader().read(source: source)
        let swType = try typeSelector(module: result.module)
        return try CodeGenerator(typeMap: typeMap ?? .default)(type: swType)
    }
}
