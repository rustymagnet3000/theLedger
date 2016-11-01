import Vapor
import Fluent
import Foundation
import HTTP
import Auth

class Name: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(3)
            && Count.max(20)
        try evaluation.validate(input: value)
    }
}

class RawUser {
    var name: Valid<Name>
    
    init(request: Request) throws {
        name = try request.data["username"].validated()
    }
}

final class User: Model {

    public var id: Node?
    var name: String
    var walletid: String
    var createddate: Int
    var exists: Bool = false // suppresses Vapor 1.1 warning
 
     convenience init(name: String) {
        let date = Date()
        let walletid = UUID().uuidString
        self.init(name: name, walletid: walletid, createddate: Int(date.timeIntervalSince1970))
    }

    init(name: String, walletid: String, createddate: Int) {
        self.name = name
        self.walletid = walletid
        self.createddate = createddate
    }
    
    init(node: Node, in context: Context) throws {

        id = try node.extract("id")
        name = try node.extract("name")
        walletid = try node.extract("walletid")
        createddate = try node.extract("createddate")
    }
    
 func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "walletid": walletid,
            "name": name,
            "createddate": createddate
            ])
    }
}

    
extension User: Preparation {
    static func prepare(_ database: Database) throws {

        try database.create("users") { users in
            users.id()
            users.string("name", length: nil, optional: false)
            users.string("walletid")
            users.int("createddate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

extension User {
    var date: Date {
        return Date(timeIntervalSince1970: Double(createddate))
    }
    
    var readableDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?
        
        switch credentials {
        case let id as Identifier:
            user = try User.find(id.id)
        case let apiKey as APIKey:
            user = try User.query().filter("email", apiKey.id).filter("password", apiKey.secret).first()
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found.")
        }
        
        return u
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        let registeruser = User(name: "testRegister")
        return registeruser
    }
}

import HTTP

extension Request {
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
        }
        
        return user
    }
}
