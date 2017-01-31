import Vapor
import Fluent
import Foundation
import HTTP


final class Ledger: Model {
    
    public var id: Node?
    var buyer: String
    var drinker: String
    var createddate: Int
    var exists: Bool = false // suppresses Vapor 1.1 warning
    
    convenience init(buyer: String, drinker: String) {
        let date = Date()
        self.init(buyer: buyer, drinker: drinker, createddate: Int(date.timeIntervalSince1970))
    }
    
    init(buyer: String, drinker: String, createddate: Int) {
        self.buyer = buyer
        self.drinker = drinker
        self.createddate = createddate
    }
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        buyer = try node.extract("buyer")
        drinker = try node.extract("drinker")
        createddate = try node.extract("createddate")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "drinker": drinker,
            "buyer": buyer,
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
