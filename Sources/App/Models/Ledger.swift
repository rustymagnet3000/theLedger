import Vapor
import Fluent
import Foundation
import HTTP

final class Ledger: Model {
    static var entity = "ledger"
    public var id: Node?
    var buyer: Node?
    var drinker: String
    var createddate: Int
    var ledgerentry: LedgerEntry
    var numberofdrinks: Int
    var exists: Bool = false
    
    init(buyer: Node? = nil, drinker: String, createddate: Int, ledgerentry: LedgerEntry, numberofdrinks: Int) {
        let date = Date()
        self.buyer = buyer
        self.drinker = drinker
        self.createddate = Int(date.timeIntervalSince1970)
        self.ledgerentry = ledgerentry
        self.numberofdrinks = numberofdrinks
    }
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        buyer = try node.extract("buyer")
        drinker = try node.extract("drinker")
        ledgerentry = try node.extract("ledgerentry")
        createddate = try node.extract("createddate")
        numberofdrinks = try node.extract("numberofdrinks")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "drinker": drinker,
            "buyer": buyer,
            "ledgerentry": ledgerentry.rawValue,
            "createddate": createddate,
            "numberofdrinks": numberofdrinks
            ])
    }
}

extension Ledger: Preparation {
    static func prepare(_ database: Database) throws {

            try database.create("ledger") { ledger in
                ledger.id()
                ledger.parent(LedgerUser.self, optional: false)
                ledger.string("drinker")
                ledger.int("ledgerentry")
                ledger.int("createddate")
                ledger.int("numberofdrinks")
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
