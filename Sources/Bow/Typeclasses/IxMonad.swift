import Foundation

public protocol IxMonad: IxApplicative {
    static func iflatMap<R, S, T, A, B>(_ fa: Kind3<Self, R, S, A>, _ f: @escaping (A) -> Kind3<Self, S, T, B>) -> Kind3<Self, R, T, B>
}
