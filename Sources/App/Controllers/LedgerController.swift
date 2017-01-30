import Vapor
import HTTP
import VaporMySQL

final class LedgerController {
 
    func addRoutes(drop: Droplet){
        let v0 = drop.grouped("v0")
        v0.get("version", handler: version)
        v0.post("count", handler: count)
    }
    
    func version(request: Request) throws -> ResponseRepresentable {
        
        if let db = drop.database?.driver as? MySQLDriver {
            let version = try db.raw("select version()")
            return try JSON(node: version)
        } else {
            return "no db connection"
        }
    }
    
    func count(request: Request) throws -> ResponseRepresentable {
        guard let chars_to_count = request.data["characters"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Please enter a shop")
        }

        return "The string is: \(chars_to_count.count) characters long"
    }
}
