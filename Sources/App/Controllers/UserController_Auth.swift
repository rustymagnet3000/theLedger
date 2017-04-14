import Vapor
import VaporMySQL
import Foundation
import Fluent
import HTTP
import Turnstile
import Auth

final class UserController_Auth {

    func addRoutes(drop: Droplet){

        let personal = drop.grouped("personal")
        let error = Abort.custom(status: .forbidden, message: "Invalid credentials.")
        let protect = ProtectMiddleware(error: error)
        let protected_service = personal.grouped(protect)
        protected_service.get("profile", handler: profileView)

    }

    func profileView(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            guard let name = request.query?["name"]?.string else{
                throw LedgerError.BadRequest
            }
            
            guard let user = try LedgerUser.query().filter("name", name).first() else
            {
                throw LedgerError.Unauthorized
            }

            return try drop.view.make("profile", Node(node: ["user":user, "readable_date": user.readable_date]))

        }
        catch let e as TurnstileError {
            print("bad credentials")
            return e.description
        }
    }
}



