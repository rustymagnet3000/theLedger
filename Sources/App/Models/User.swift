import Vapor
import Fluent
import Foundation
import HTTP

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
    var id: Node?
    var name: String
    var walletid: String
    var createddate: Int
    
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
    
    func makeNode() throws -> Node {
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
            users.id("id")
            users.string("name")
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
