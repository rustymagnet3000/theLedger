import Vapor
import VaporMySQL
import Foundation
import Fluent
import HTTP

final class LedgerController {
 
    func addSmokeRoutes(drop: Droplet){
        let v0 = drop.grouped("v0")
        v0.get("version", handler: version)
        v0.get("healthcheck", handler: healthcheck)
        v0.post("count", handler: count)
    }

    func addRoutes(drop: Droplet){
        let v2 = drop.grouped("v2")
        v2.post("buy", handler: buy)
        v2.get("transactions", handler: transcations)
        v2.get("ledger", handler: ledger)
            
    }
    
    func ledger(request: Request) throws -> ResponseRepresentable {
 
        let users = try [
            ["name": "bob", "id": "1111"].makeNode(),
            ["name": "alice", "id": "2222"].makeNode(),
            ["name": "yves", "id": "3333"].makeNode()
        ].makeNode()
        
        return try drop.view.make("ledger", Node(node: ["users": users]))
    }
    
    func transcations(request: Request) throws -> ResponseRepresentable {
        
        let history_purchases: [Ledger]
        
        guard let customer = request.query?["customer_walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        do {
            let customer_in_db = try User.query().filter("walletid", customer).first()
            guard customer_in_db != nil else { throw LedgerError.Unauthorized }
        }
        catch {
            throw LedgerError.Unauthorized
        }

        do {
            history_purchases = try Ledger.query().filter("buyer", .equals, customer).all()
        }
        catch {
            throw Abort.custom(status: .badRequest, message: "Problem retrieving transactions.")
        }
        

        return try JSON(node: history_purchases)

    }
    
    func buy(request: Request) throws -> ResponseRepresentable {
      
        let buyer_in_db: User?
        
        guard let buyer = request.data["buyer_walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        do {
            buyer_in_db = try User.query().filter("walletid", buyer).first()
            guard buyer_in_db != nil else { throw LedgerError.Unauthorized }
        }
        catch {
            throw LedgerError.Unauthorized
        }
    
        guard let drinker_array = request.data["drinker_walletid"]?.array else {
            throw LedgerError.BadRequest
        }
    
        for unknown_drinker in drinker_array {

            guard let drinker = unknown_drinker.string else { throw LedgerError.BadRequest }
            if drinker.isEmpty { throw LedgerError.BadRequest } /* validate parameter is present but not null */
            if buyer == drinker { throw LedgerError.Unauthorized } /* validate buyer not also drinker */
            
            do {
                let drinker_in_db: User? = try User.query().filter("walletid", drinker).first()
                guard drinker_in_db != nil else { throw LedgerError.Unauthorized }
            }
            catch {
                throw LedgerError.Unauthorized
            }
        
            let node: Node? = "7D60EB8D-9941-4BBE-BE34-376499CFA802"
            do {
                var ledgerRecord = Ledger(buyer: node, drinker: drinker, createddate: 0, ledgerentry: .Purchased, numberofdrinks: 1)
                
                try ledgerRecord.save()
            }
    
            catch {
                throw LedgerError.DatabaseError
            }
        }
        
        return try JSON(node: [
            "buyer": buyer_in_db?.name,
            "drinkers": "\(drinker_array.count)"
            ])
    }
    
    func version(request: Request) throws -> ResponseRepresentable {
        
        if let db = drop.database?.driver as? MySQLDriver {
            let version = try db.raw("select version()")
            return try JSON(node: version)
        } else {
            throw LedgerError.ServiceUnavailable
        }
    }
    
    func healthcheck(request: Request) throws -> ResponseRepresentable {
        let version = VERSION
        return try JSON(node: "Vapor version \(version)")
    }
    
    func count(request: Request) throws -> ResponseRepresentable {

        guard let chars_to_count = request.data["characters"]?.string else {
            throw LedgerError.BadRequest
        }
        
        let validated_chars_to_count = try chars_to_count.validated(by: Count.min(5) && OnlyAlphanumeric.self)

        return "The string is: \(validated_chars_to_count.value.count) characters long"
    }

}
