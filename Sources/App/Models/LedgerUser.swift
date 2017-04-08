import Vapor
import Fluent
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import Auth

final class LedgerUser: Model, User {
    static var entity = "ledgeruser"
    public var id: Node?
    var name: Valid<NameValidator>
    var password: String
    var walletid: String
    var createddate: Int
    var exists: Bool = false // suppresses Vapor 1.1 warning
 
    convenience init(name: String, raw_password: String) throws {
        let date = Date()
        let walletid = UUID().uuidString
        try self.init(name: name, password: raw_password, walletid: walletid, createddate: Int(date.timeIntervalSince1970))
    }

    init(name: String, password: String, walletid: String, createddate: Int) throws {
            self.name = try name.validated()
            self.password = BCrypt.hash(password: password)
            self.walletid = walletid
            self.createddate = createddate
    }
    
    init(node: Node, in context: Context) throws {

        id = try node.extract("id")
        let name_string = try node.extract("name") as String
        name = try name_string.validated()
        walletid = try node.extract("walletid")
        createddate = try node.extract("createddate")
        let password_string = try node.extract("password") as String
        password = password_string
    }
    
 func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "walletid": walletid,
            "name": name.value,
            "password": password,
            "createddate": createddate
            ])
    }
    static func register(name: String, password: String) throws -> LedgerUser {
        var new_user = try LedgerUser(name: name, raw_password: password)

        if try LedgerUser.query().filter("name", name).first() == nil {
            try new_user.save()
            return new_user
        } else {
            throw LedgerError.AlreadyRegistered
        }
    }
}
    
extension LedgerUser: Preparation {
    static func prepare(_ database: Database) throws {

        try database.create(entity) { users in
            users.id()
            users.string("name", length: nil, optional: false)
            users.string("password")
            users.string("walletid")
            users.int("createddate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

extension LedgerUser {
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

extension LedgerUser: Authenticator {
    
    static func authenticate(credentials: Credentials) throws -> User {
        var user: LedgerUser?
        
        switch credentials {
        
        case let credentials as UsernamePassword:
            let fetched_user = try LedgerUser.query()
                .filter("name", credentials.username)
                .first()
            if let password = fetched_user?.password,
                password != "",
                (try BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetched_user
            }
        case let credentials as Identifier:
            user = try LedgerUser.find(credentials.id)
        
        case let accessToken as AccessToken:
            user = try LedgerUser.query().filter("access_token", accessToken.string).first()
            
        default:
            throw LedgerError.BadCredentials
        }
    
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    static func register(credentials: Credentials) throws -> User {
        throw Abort.custom(status: .badGateway, message: "in register func")
    }
}
