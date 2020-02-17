import Foundation

public protocol IxFunctor {
    static func imap<SI, S, A, B>(_ fa: Kind3<Self, SI, S, A>, _ f: @escaping (A) -> B) -> Kind3<Self, SI, S, B>
}
