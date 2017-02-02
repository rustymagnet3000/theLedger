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



drop.group("v1") { v1 in
        
    v1.post("sendsecret") { request in
    
        guard let encrypted_message = request.data["encrypted_message"] else {
            throw LedgerError.BadRequest
        }

        return JSON("Server alive")
    }
    
    v1.post("registeruser")     { request in
        
        guard let credentials = request.auth.header?.basic else {
            throw LedgerError.Unauthorized
        }
        
        //   let key = APIKey(id: credentials.id, secret: credentials.secret)
        
        var registeruser: User!
        do {
            //       var result = try request.auth.header(key)
            var cleaneduser = try RawUser(request: request)
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
            "Result": true
            ])
    }

    v1.get("allusers", String.self)     { request, untrustedWalletID in
        
        guard let walletid = untrustedWalletID.string else {
            throw Abort.badRequest
        }
        
        do {
            guard let validatedWalletID = try User.query().filter("walletid", walletid).first() else
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
