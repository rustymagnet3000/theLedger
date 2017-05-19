import Foundation

public class Nonce { // MARK: add to public class ProtectMiddleware: Middleware
    
    private var array_of_nonces: [Int] = []
    private let array_max = 3
    
    func get_nonce() throws -> Int {
        
        if array_of_nonces.count == 3 {
            array_of_nonces.remove(at: 0)
        }
        
        let new_nonce = Int(arc4random_uniform(5))
        array_of_nonces += [new_nonce]
        
        return new_nonce
    }
    
    func print_nonces() throws -> Void {
        print("\nLast added \(array_of_nonces.last!)")
        for number in array_of_nonces {
            print(number)
        }
    }
    
    func verify_nonce_in_memory(unverified_nonce: Int) -> Bool {
        
        for number in array_of_nonces {
            print("\nCheck if \(unverified_nonce) == \(number)")
            if number == unverified_nonce {
                return true
            }
        }
        return false
    }
}
