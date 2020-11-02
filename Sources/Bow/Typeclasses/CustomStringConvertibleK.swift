import Foundation

/// EquatableK provides capabilities to convert a value to a string at the kind level.
public protocol CustomStringConvertibleK {
    static func description<A: CustomStringConvertible>(of fa: Kind<Self, A>) -> String
}

extension Kind: CustomStringConvertible where F: CustomStringConvertibleK, A: CustomStringConvertible {

    public var description: String {
        F.description(of: self)
    }
}
