import Vapor
import VaporMySQL
import Foundation
import Fluent

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.middleware.append(SampleMiddleware())

drop.group("v1") { v1 in
    v1.get("users") { request in
        return "works"
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
}

drop.get("allusers", String.self)     { request, untrustedWalletID in
    
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

drop.get(String.self, "deleteuser")     { request, untrustedUser in
    
    // Mark: Input value must be a string. doesn't check for nil.
    guard let VerifiedUser = untrustedUser.string else {
        throw Abort.badRequest
    }
    
    do {
        if let ledgeruser = try User.query().filter("name", VerifiedUser).first() {
            try ledgeruser.delete()
            return try JSON(node: [
                "name": VerifiedUser,
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

drop.get("countcharacters", String.self) { request, unTrustedChars in
    guard let validatedChars = unTrustedChars.string else {
        throw Abort.badRequest
    }
    return "The string is: \(validatedChars.count) characters long"
}

drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.run()
