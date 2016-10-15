import Vapor
import HTTP
import VaporMySQL


let drop = Droplet(preparations:[User.self], providers: [VaporMySQL.Provider.self])

drop.post("registeruser")     { request in
    var registeruser: User
    
    do {
        let username = request.data["userName"]?.string
        registeruser = User(name: username!)
        try registeruser.save()
    }
    catch let error as ValidationErrorProtocol {
        print(error.message)
        print(request.body)
        throw Abort.custom(status: .badRequest, message: "User registration failed")
    }
    
    return try JSON(node: [
        "User ID": registeruser.id,
        "Username": registeruser.name,
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
