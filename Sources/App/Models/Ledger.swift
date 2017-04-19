import Vapor
import Fluent
import Foundation
import HTTP

final class Ledger: Model {
    static var entity = "ledger"
    public var id: Node?
    var ledgeruser_id: Node?
    var drinker: String
    var createddate: Int
    var ledgerentry: LedgerEntry
    var numberofdrinks: Int
    var exists: Bool = false
    
    init(ledgeruser_id: Node? = nil, drinker: String, createddate: Int, ledgerentry: LedgerEntry, numberofdrinks: Int) {
        let date = Date()
        self.ledgeruser_id = ledgeruser_id
        self.drinker = drinker
        self.createddate = Int(date.timeIntervalSince1970)
        self.ledgerentry = ledgerentry
        self.numberofdrinks = numberofdrinks
    }
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        ledgeruser_id = try node.extract("ledgeruser_id")
        drinker = try node.extract("drinker")
        ledgerentry = try node.extract("ledgerentry")
        createddate = try node.extract("createddate")
        numberofdrinks = try node.extract("numberofdrinks")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "ledgeruser_id": ledgeruser_id,
            "drinker": drinker,
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
                ledger.int("createddate")
                ledger.int("ledgerentry")
                ledger.int("numberofdrinks")
                
            }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("ledger")
    }
}

extension Ledger {
    func buyer() throws -> LedgerUser? {
        
        return try parent(ledgeruser_id, nil, LedgerUser.self).get()
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
