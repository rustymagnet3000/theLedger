import Vapor
import Fluent
import Foundation
import HTTP

enum LedgerEntry: Int {
    case Purchased = 0, Disputed, Refunded
}

final class Ledger: Model {
    static var entity = "ledger"
    public var id: Node?
    var buyer: String
    var drinker: String
    var createddate: Int
    var ledgertype: LedgerEntry
    var exists: Bool = false // suppresses Vapor 1.1 warning
    
    convenience init(buyer: String, drinker: String) {
        let date = Date()
        self.init(buyer: buyer, drinker: drinker, createddate: Int(date.timeIntervalSince1970), ledgertype: .Purchased)
    }
    
    init(buyer: String, drinker: String, createddate: Int, ledgertype: LedgerEntry) {
        self.buyer = buyer
        self.drinker = drinker
        self.createddate = createddate
        self.ledgertype = LedgerEntry(rawValue: ledgertype.rawValue)!
    }
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        buyer = try node.extract("buyer")
        drinker = try node.extract("drinker")
        ledgertype = try node.extract("ledgertype")
        createddate = try node.extract("createddate")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "drinker": drinker,
            "buyer": buyer,
            "ledgertype": ledgertype,
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
                ledger.int("ledgertype")
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
