import Foundation

public protocol IxMonadState: IxMonad {
    static func iget<A>(_ a: A) -> Kind3<Self, A, A, A>
    static func iset<SI, SO>(_ so: SO) -> Kind3<Self, SI, SO, ()>
}
