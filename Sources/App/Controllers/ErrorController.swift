
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
