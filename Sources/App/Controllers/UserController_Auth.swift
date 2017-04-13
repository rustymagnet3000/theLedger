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
        protected_service.get("profile", handler: profile)

    }
    
    func profile(request: Request) throws -> ResponseRepresentable {
        
        do {
            
            return try drop.view.make("profile")
        }
        catch let e as TurnstileError {
            print("bad credentials")
            return e.description
        }
    }
}



