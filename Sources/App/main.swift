import Vapor
import HTTP
import VaporMySQL
import Foundation
import Auth

let drop = Droplet(preparations:[User.self], providers: [VaporMySQL.Provider.self])

drop.post("registeruser")     { request in
    
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    var registeruser: User!
    do {
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

drop.get("allusers", String.self)     { request, untrustedWalletID in
    
    guard let walletid = untrustedWalletID.string else {
        throw Abort.badRequest
    }
        do {
            let validatedWalletID = try User.query().filter("walletid", walletid).first()

            let allUsers = try User.query().filter("id", .greaterThanOrEquals, 1).all()

            for i in allUsers {
                print("Hello \(i.name)")
            }
            return try JSON(node: allUsers)

        } catch {
            throw Abort.custom(status: .badRequest, message: "You are not authorized to search.")
        }
}

drop.get("countcharacters", String.self) { request, name in
    return "The string is: \(name.count) characters long"
}

drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.get("plaintext") { request in
    return "Hello, World!"
}

drop.middleware.append(SampleMiddleware())

drop.serve()
