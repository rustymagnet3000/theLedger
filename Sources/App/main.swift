import Vapor
import VaporMySQL
import Foundation
import Fluent

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.preparations.append(Ledger.self)

drop.middleware.append(VersionMiddleware())
drop.middleware.append(FooErrorMiddleware())

let ledger = LedgerController()
ledger.addRoutes(drop: drop)
ledger.addSmokeRoutes(drop: drop)



drop.group("v1") { v1 in
        
    v1.post("sendsecret") { request in
    
        guard let encrypted_message = request.data["encrypted_message"] else {
            throw Abort.custom(status: .badRequest, message: "Please enter a secret")
        }

        return JSON("Server alive")
    }
    
    v1.post("registeruser")     { request in
        
        guard let credentials = request.auth.header?.basic else {
            throw Abort.custom(status: .unauthorized, message: "Unauthorized - No basic auth creds")
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
            throw Abort.custom(status: .badRequest, message: "User registration failed")
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
            throw Abort.custom(status: .badRequest, message: "You are not authorized to search.")
        }
    }
    
    v1.get(String.self, "deleteuser")     { request, rawUsername in
        
        do {
            guard let verifiedUser = rawUsername.string else {
                throw Abort.badRequest
            }
            guard let usernameExists = try User.query().filter("name", verifiedUser).first() else
            {
                throw Abort.custom(status: .badRequest, message: "You are not authorized to perform this search.")
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
            throw Abort.custom(status: .unauthorized, message: "We are having a problem. Please try again.")
        }
        
    }
}


drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.run()
