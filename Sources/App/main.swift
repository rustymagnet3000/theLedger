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
        "ID": registeruser.id,
        "Wallet ID": registeruser.walletid,
        "Username": registeruser.name,
        "Created on": registeruser.readableDate,
        "Result": true
        ])
}

drop.get(String.self, "allusers")     { request, userSearching in
    // Mark: name of person performing the search for logging
//userSearching
    return "\(userSearching) attempted to list all users."
}

drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.get("plaintext") { request in
    return "Hello, World!"
}

drop.middleware.append(SampleMiddleware())

drop.serve()
