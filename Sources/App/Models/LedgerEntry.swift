import Vapor

enum LedgerEntry: Int {
    case Purchased = 0, Disputed, Refunded
    
    func simpleDescription() -> String {
        switch self {
        case .Purchased:
            return "purchase"
        case .Disputed:
            return "dispute"
        case .Refunded:
            return "refund"
        }
    }
}

extension LedgerEntry: NodeInitializable {
    
    init(node: Node, in context: Context) throws {
        
        guard let rawValue = node.int, let value = LedgerEntry(rawValue: rawValue) else {
            throw NodeError.unableToConvert(node: node, expected: "int")
        }
        
        self = value
    }
}
