import Vapor
import Fluent
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto

class RawUser {
    var name: Valid<Name>
    
    init(request: Request) throws {
        name = try request.data["username"].validated()
    }
}

final class User: Model {
    static var entity = "ledgeruser"
    public var id: Node?
    var name: String
    var password: String
    var walletid: String
    var createddate: Int
    var exists: Bool = false // suppresses Vapor 1.1 warning
 
    convenience init(name: String,  raw_password: String) {
        let date = Date()
        let walletid = UUID().uuidString

        self.init(name: name, password: raw_password, walletid: walletid, createddate: Int(date.timeIntervalSince1970))
    }

    init(name: String, password: String, walletid: String, createddate: Int) {
        self.name = name
        self.walletid = walletid
        self.createddate = createddate
        let validated_password: Valid<PasswordValidator> = try raw_password.validated()
        self.password = BCrypt.hash(password: validated_password.value)
    }
    
    init(node: Node, in context: Context) throws {

        id = try node.extract("id")
        name = try node.extract("name")
        walletid = try node.extract("walletid")
        createddate = try node.extract("createddate")
        let password_string = try node.extract("password") as String
        password = password_string
    }
    
 func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "walletid": walletid,
            "name": name,
            "password": password,
            "createddate": createddate
            ])
    }
}
    
extension User: Preparation {
    static func prepare(_ database: Database) throws {

        try database.create(entity) { users in
            users.id()
            users.string("name", length: nil, optional: false)
            users.string("walletid")
            users.int("createddate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
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
