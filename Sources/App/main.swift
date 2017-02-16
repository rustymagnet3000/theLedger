import Vapor
import VaporMySQL
import Foundation
import Fluent

let drop = Droplet()

drop.preparations.append(User.self)
drop.preparations.append(Ledger.self)

try drop.addProvider(VaporMySQL.Provider.self)

drop.middleware.append(VersionMiddleware())
drop.middleware.append(LedgerErrorMiddleware())

let ledger = LedgerController()
ledger.addRoutes(drop: drop)
ledger.addSmokeRoutes(drop: drop)

let user = UserController()
user.addRoutes(drop: drop)


drop.group("v1") { v1 in
        

    
    v1.get(String.self, "deleteuser")     { request, rawUsername in
        
        do {
            guard let verifiedUser = rawUsername.string else {
                throw LedgerError.BadRequest
            }
            guard let usernameExists = try User.query().filter("name", verifiedUser).first() else
            {
                throw LedgerError.Unauthorized
            }
            
            if let ledgeruser = try User.query().filter("name", usernameExists.name).first() {
                try ledgeruser.delete()
                return try JSON(node: [
                    "name": verifiedUser,
                    "status": true
                    ])
            } else {
                throw Abort.custom(status: .unauthorized, message: "MARK - user not found.")
            }
        }
        catch {
            throw LedgerError.Unauthorized
        }
        
    }
}

drop.get("/") { request in
    return try drop.view.make("welcome.html")
}


drop.run()
