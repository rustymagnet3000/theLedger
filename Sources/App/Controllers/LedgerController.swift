import Vapor
import VaporMySQL
import Foundation
import Fluent
import HTTP

final class LedgerController {
 
    func addRoutes(drop: Droplet){
        let v2 = drop.grouped("v2")
        v2.post("buy", handler: buy)
        v2.get("transactions", handler: transcations)
        v2.get(LedgerUser.self, "user_transactions", handler: transcationsIndex)
        v2.get(Ledger.self, "transaction_buyer", handler: transaction_buyer)
    }

    func transcationsIndex(request: Request, ledgeruser: LedgerUser) throws -> ResponseRepresentable {
        let children = try ledgeruser.transactions()
        return try JSON(node: children.makeNode())
    }
    
    func transaction_buyer(request: Request, ledger: Ledger) throws -> ResponseRepresentable {
        guard let ledgeruser = try ledger.buyer() else {
            throw LedgerError.NoRecords
        }
        return try JSON(node: ledgeruser.makeNode())
    }
    
    func transcations(request: Request) throws -> ResponseRepresentable {
        
        let history_purchases: [Ledger]
        
        guard let customer = request.query?["customer_walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        do {
            let customer_in_db = try LedgerUser.query().filter("walletid", customer).first()
            guard customer_in_db != nil else { throw LedgerError.Unauthorized }

            history_purchases = try Ledger.query().filter("ledgeruser_id", .equals, (customer_in_db?.id)!).all()
        }
        catch {
            throw Abort.custom(status: .badRequest, message: "Problem retrieving transactions.")
        }

        return try JSON(node: history_purchases)
    }
    
    func buy(request: Request) throws -> ResponseRepresentable {
      
        guard let buyer = request.data["buyer_walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        guard let number_of_drinks = request.data["drink_number"]?.int else {
            throw LedgerError.BadRequest
        }
        
        do {
            
            let buyer_in_db = try LedgerUser.query().filter("id", buyer).first()
            
            guard buyer_in_db != nil else {
                    throw LedgerError.Unauthorized
            }
            
            guard let drinker_array = request.data["drinker_walletid"]?.array else {
                throw LedgerError.BadRequest
            }
    
            for unknown_drinker in drinker_array {

                guard let drinker = unknown_drinker.string else { throw LedgerError.BadRequest }
                if drinker.isEmpty { throw LedgerError.BadRequest } /* validate parameter is present but not null */
                if buyer == drinker { throw LedgerError.BadRequest } /* validate buyer not also drinker */
                
                var ledgerRecord = Ledger(ledgeruser_id: buyer_in_db?.id, drinker: drinker, createddate: 0, ledgerentry: .Purchased, numberofdrinks: number_of_drinks)
                
                try ledgerRecord.save()
            }
        
            return try JSON(node: buyer_in_db)
        }
    }
}
