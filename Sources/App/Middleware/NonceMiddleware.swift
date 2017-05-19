import Vapor
import HTTP

final class NonceMiddleware: Middleware {
    
    public let nonce = Nonce()

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
     
        let response = try next.respond(to: request)
        
        let new_nonce = try nonce.get_nonce()
        try nonce.print_nonces()
        response.headers["Nonce"] = "\(new_nonce)"

        return response
    }
}

//guard let recieved_nonce = request.headers["Nonce"]?.string
//    else {
//        throw Abort.badRequest
//}

