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
        
        var registeruser: User!
        
        do {
            registeruser = User(name: (request.data["username"]?.string)!)
            try registeruser.save()
        }
        catch let error as ValidationErrorProtocol {
            print(error.message)
            throw LedgerError.DatabaseError
        }
        
        return try JSON(node: [
        "WalletID": registeruser.walletid,
        "Username": registeruser.name,
        "CreatedDate": registeruser.readableDate,
        "Result": true])
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        
        guard let walletid = request.query?["walletid"]?.string else {
            throw LedgerError.BadRequest
        }
        
        do {
            guard let _ = try User.query().filter("walletid", walletid).first() else
            {
                throw Abort.custom(status: .badRequest, message: "You are not authorized to perform this search.")
            }
            
            let allUsers = try User.query().filter("id", .greaterThanOrEquals, 1).all()
            return try JSON(node: allUsers)
        }
        catch {
            throw LedgerError.DatabaseError
        }
    }
    
    func delete(request: Request) throws -> ResponseRepresentable {

        /* not exposed to mobile app */
        guard let name = request.query?["name"]?.string else{
            throw LedgerError.BadRequest
        }

        guard let usernameExists = try User.query().filter("name", name).first() else{
            throw LedgerError.Unauthorized
        }
        
        if let ledgeruser = try User.query().filter("name", usernameExists.name).first() {
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
