import Vapor

class PasswordValidator: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(3)
            && Count.max(20)
        try evaluation.validate(input: value)
    }
}

class NameValidator: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(3)
            && Count.max(20)
        try evaluation.validate(input: value)
    }
}
