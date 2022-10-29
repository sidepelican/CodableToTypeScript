public struct TSCallExpr: PrettyPrintable {
    public var callee: TSExpr
    public var arguments: [TSFunctionArgument]

    public init(callee: TSExpr, arguments: [TSFunctionArgument]) {
        self.callee = callee
        self.arguments = arguments
    }

    public func print(printer: PrettyPrinter) {
        callee.print(printer: printer)
        arguments.print(printer: printer)
    }
}
