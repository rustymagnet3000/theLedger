
enum LedgerError: Error {
    case ServiceUnavailable
    case BadRequest
    case PageNotFound
    case DatabaseError
    case Unauthorized
    case UnknownError
    case AlreadyRegistered
    case NoRecords
    case BadCredentials
}


enum ValidatorError: Error {
    case BadPassword
}


enum AuthorizationError: Error {
    case badCookie
    case badNonce
    
    func description() -> String {
        switch self {
        case .badCookie:
            return "bad Cookie"
        case .badNonce:
            return "bad Nonce"
        }
    }
}
