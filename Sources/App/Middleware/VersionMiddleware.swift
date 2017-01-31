import Vapor
import HTTP

final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        response.headers["Version"] = "API version: BETAs"
        
        return response
    }
}

class FooErrorMiddleware: Middleware {

	func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        do {
            let response = try next.respond(to: request)
            response.headers["Version"] = "API version: BETAs" // Not working: bug?
        
            return response
        }
        catch FooError.FooServiceUnavailable {
            throw Abort.custom(
                status: .serviceUnavailable,
                message: "Sorry, we were unable to query the Foo service."
            )
        }
        catch FooError.FooBadRequest {
            throw Abort.custom(
                status: .badRequest,
                message: "Sorry, bad request."
            )
        }
    }
}


import Turnstile

/**
 Takes a Basic Authentication header and turns it into a set of API Keys,
 and attempts to authenticate against it.
 */
class BasicAuthenticationMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }
        
        return try next.respond(to: request)
    }
}
