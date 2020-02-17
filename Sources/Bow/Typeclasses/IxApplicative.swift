import Foundation

public protocol IxApplicative: IxFunctor {
    static func ipure<R, S, A>(_ a: A) -> Kind3<Self, R, S, A>
    static func iap<R, S, T, A, B>(_ ff: Kind3<Self, R, S, (A) -> B>, _ fa: Kind3<Self, S, T, A>) -> Kind3<Self, R, T, B>
}
