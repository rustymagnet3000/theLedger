import Vapor
import HTTP

final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        response.headers["Version"] = "API version: BETAs"
        
        return response
    }
}

class LedgerErrorMiddleware: Middleware {

	func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        do {
            let response = try next.respond(to: request)
            response.headers["Version"] = "API version: BETAs" // Not working: bug?
        
            return response
        }

        catch LedgerError.NoRecords {
            throw Abort.custom(
                status: .badRequest,
                message: "Sorry, no records to return."
            )
        }

        catch LedgerError.BadCredentials {
            throw Abort.custom(
                status: .unauthorized,
                message: "Bad credentials."
            )
        }
            
        catch LedgerError.AlreadyRegistered {
            throw Abort.custom(
                status: .badRequest,
                message: "Sorry, already registered."
            )
        }
            
        catch LedgerError.ServiceUnavailable {
            throw Abort.custom(
                status: .serviceUnavailable,
                message: "Sorry, we were unable to query the Foo service."
            )
        }
        catch LedgerError.BadRequest {
            throw Abort.custom(
                status: .badRequest,
                message: "Sorry, bad request."
            )
        }
        catch LedgerError.Unauthorized {
            throw Abort.custom(
                status: .unauthorized,
                message: "Sorry, you are not authorized."
            )
        }
        catch LedgerError.DatabaseError {
            throw Abort.custom(
                status: .internalServerError,
                message: "Sorry, please contact system admin."
            )
        }
    }
}
