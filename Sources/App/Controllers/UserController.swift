import Vapor
import VaporMySQL
import Foundation
import Fluent
import HTTP

final class UserController {
        
    func addRoutes(drop: Droplet){
        let user = drop.grouped("user")
        user.get("version", handler: version)
        user.post("register", handler: register)
        user.get("all", handler: all)
        user.get("delete", handler: delete)
    }
    
    func version(request: Request) throws -> ResponseRepresentable {
        
        if let db = drop.database?.driver as? MySQLDriver {
            let version = try db.raw("select version()")
            return try JSON(node: version)
        } else {
            throw LedgerError.ServiceUnavailable
        }
    }

    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw LedgerError.BadRequest
        }
        
        guard let untrusted_password = request.data["password"]?.string else {
            throw LedgerError.BadRequest
        }
        
        do {
            var registeruser = LedgerUser(name: username, raw_password: untrusted_password)
            
            try registeruser.save()
            
            return try JSON(node: [
                "WalletID": registeruser.walletid,
                "Username": registeruser.name,
                "CreatedDate": registeruser.readableDate,
                "Result": true])
        }
        catch let error as ValidationErrorProtocol {
            print(error.message)
            throw LedgerError.DatabaseError
        }
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        
        guard let walletid = request.query?["walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        guard let _ = try LedgerUser.query().filter("walletid", walletid).first() else
        {
            throw LedgerError.Unauthorized
        }
        
        do {
            let allUsers = try LedgerUser.query().filter("id", .greaterThanOrEquals, 1).all()
            // MARK: need to add a check here for zero users returned (although would never be invoked at the moment
            return try JSON(node: allUsers)
        }
        catch {
            throw LedgerError.NoRecords
        }
    }
    
    func delete(request: Request) throws -> ResponseRepresentable {

        /* not exposed to mobile app */
        guard let name = request.query?["name"]?.string else{
            throw LedgerError.BadRequest
        }

        guard let usernameExists = try LedgerUser.query().filter("name", name).first() else{
            throw LedgerError.Unauthorized
        }
        
        if let ledgeruser = try LedgerUser.query().filter("name", usernameExists.name).first() {
            try ledgeruser.delete()
            return try JSON(node: [
                "name": name,
                "status": "Deleted"
                ])
        }
        else {
            throw Abort.custom(status: .unauthorized, message: "MARK - user not found.")
        }
    }
}
