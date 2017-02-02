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
    }
    
    func buy(request: Request) throws -> ResponseRepresentable {
      
        var ledgerEntry: Ledger
        
        do {
            let buyer = request.data["buyer"]?.string
            let drinker = request.data["drinker"]?.string
            ledgerEntry = Ledger(buyer: buyer!, drinker: drinker!, ledgerentry: .Purchased)
            
            try ledgerEntry.save()
        }
            
        catch {
            print(error)
            throw LedgerError.DatabaseError
        }
        
        return try JSON(node: [
            "buyer": ledgerEntry.buyer,
            "drinker": ledgerEntry.drinker,
            "CreatedDate": ledgerEntry.readableDate,
            "Entry type":  ledgerEntry.ledgerentry.simpleDescription(),
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
