import Vapor
import HTTP
import VaporMySQL
import Foundation

let drop = Droplet(preparations:[User.self], providers: [VaporMySQL.Provider.self])

drop.post("registeruser")     { request in
    
    let username = request.data["username"]?.string
    var registeruser = User(name: username!)
    
    do {
      try registeruser.save()
    }
    catch let error as ValidationErrorProtocol {
        print(error.message)
        print(request.body)
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
