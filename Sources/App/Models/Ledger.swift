import Vapor
import Fluent
import Foundation
import HTTP

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

final class Ledger: Model {
    static var entity = "ledger"
    public var id: Node?
    var buyer: String
    var drinker: String
    var createddate: Int
    var ledgerentry: LedgerEntry
    var exists: Bool = false
    
    convenience init(buyer: String, drinker: String, ledgerentry: LedgerEntry) {
        let date = Date()
        self.init(buyer: buyer, drinker: drinker, createddate: Int(date.timeIntervalSince1970), ledgerentry: ledgerentry)
    }
    
    init(buyer: String, drinker: String, createddate: Int, ledgerentry: LedgerEntry) {
        self.buyer = buyer
        self.drinker = drinker
        self.createddate = createddate
        self.ledgerentry = ledgerentry
    }
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        buyer = try node.extract("buyer")
        drinker = try node.extract("drinker")
        ledgerentry = try node.extract("ledgerentry")
        createddate = try node.extract("createddate")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "drinker": drinker,
            "buyer": buyer,
            "ledgerentry": ledgerentry.rawValue,
            "createddate": createddate
            ])
    }
}


        
extension Ledger: Preparation {
    static func prepare(_ database: Database) throws {

            try database.create("ledger") { ledger in
                ledger.id()
                ledger.string("drinker")
                ledger.string("buyer")
                ledger.int("ledgerentry")
                ledger.int("createddate")
            }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("ledger")
    }
}

extension Ledger {
    var date: Date {
        return Date(timeIntervalSince1970: Double(createddate))
    }
    
    var readableDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
