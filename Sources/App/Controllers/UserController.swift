import Vapor
import VaporMySQL
import Foundation
import Fluent
import HTTP
import Turnstile

final class UserController {
        
    func addRoutes(drop: Droplet){
        let user = drop.grouped("user")
        user.post("register", handler: register)
        user.get("all", handler: all)
        user.get("delete", handler: delete)
        user.get("ledgerusers", handler: ledgerusers)
        user.get("login", handler: loginView)
        user.post("login", handler: login)
        user.get("register", handler: registerView)
        user.post("register", handler: register)
    }
    
    func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    func login(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw LedgerError.BadRequest
        }
        
        guard let password = request.data["password"]?.string else {
            throw LedgerError.BadRequest
        }
        
        let credentials = UsernamePassword(username: name, password: password)
        
        do {
            try request.auth.login(credentials)
            return try drop.view.make("loggedin")
        }
        catch let e as TurnstileError {
            print("bad credentials")
            return e.description
        }
    }
    
    func registerView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("register")
    }
    
    /* handle the posted form - request.data handles both URL encoded forms and json */
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw LedgerError.BadRequest
        }
        
        guard let password = request.data["password"]?.string else {
            throw LedgerError.BadRequest
        }
        
        let registered_user = try LedgerUser.register(name: name, password: password)
        
        switch (request.headers["Content-Type"]! as String) {

            case "application/x-www-form-urlencoded":
                return Response(redirect: "/user/ledgerusers")
        
            default:
                return try JSON(node: registered_user)
        }
        
    }
    
    func ledgerusers(request: Request) throws -> ResponseRepresentable {
        
        let users = try LedgerUser.query().filter("id", .greaterThanOrEquals, 1).all().makeNode()
        
        return try drop.view.make("ledgerusers", Node(node: ["users": users]))
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

        guard let name = request.query?["name"]?.string else{
            throw LedgerError.BadRequest
        }

        guard let usernameExists = try LedgerUser.query().filter("name", name).first() else{
            throw LedgerError.Unauthorized
        }
        
        if let ledgeruser = try LedgerUser.query().filter("name", usernameExists.name.value).first() {
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

extension HTTP.KeyAccessible where Key == HeaderKey, Value == String {
    var customKey: String? {
        get {
            return self["Custom-Key"]
        }
        set {
            self["Custom-Key"] = newValue
        }
    }
}
