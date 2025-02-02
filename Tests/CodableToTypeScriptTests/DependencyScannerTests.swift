import XCTest
@testable import CodableToTypeScript
import SwiftTypeReader
import TSCodeModule

final class DependencyScannerTests: XCTestCase {
    func testGenericStruct() throws {
        let tsCode = try Utils.generate(
            source: """
struct S<T, U> {
    var a: A?
    var b: number
    var c: [B]
    var t: T
    var sc: S<C>
    var st: R<U>
}
""",
            type: { $0.name == "S" }
        )

        let imp = try XCTUnwrap(tsCode.decls.compactMap { (x) -> TSImportDecl? in
            switch x {
            case .importDecl(let d): return d
            default: return nil
            }
        }.first)

        XCTAssertEqual(imp.names, ["A", "B", "C", "R"])
    }
}
