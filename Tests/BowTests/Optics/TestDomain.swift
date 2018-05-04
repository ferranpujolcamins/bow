import SwiftCheck
@testable import Bow

struct Token {
    static var eq : TokenEq {
        return TokenEq()
    }
    let value : String
}

extension Token : Arbitrary {
    static var arbitrary: Gen<Token> {
        return String.arbitrary.map(Token.init)
    }
}

class TokenEq : Eq {
    typealias A = Token
    
    func eqv(_ a: Token, _ b: Token) -> Bool {
        return a.value == b.value
    }
}

let tokenIso = Iso(get: { (token : Token) in token.value }, reverseGet: Token.init )
