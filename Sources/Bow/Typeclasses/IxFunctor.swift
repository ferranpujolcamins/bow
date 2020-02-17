import Foundation

public protocol IxFunctor {
    static func imap<SI, SO, A, B>(_ fa: Kind<Kind2<Self, SI, SO>, A>, _ f: @escaping (A) -> B) -> Kind<Kind2<Self, SI, SO>, B>
}
