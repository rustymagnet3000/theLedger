import Vapor
import HTTP

final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        let vaporVersion = VERSION
        response.headers["Version"] = "Vapor: \(vaporVersion)"
        return response
    }
}
