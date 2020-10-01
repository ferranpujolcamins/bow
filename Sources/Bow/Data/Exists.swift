import Foundation

public final class Exists<F> {
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = fa
    }
    let fa: Any

    // (∀X. F<X> -> R) -> R
    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        switch fa {
        case let fi as Kind<F, Int>:
            return f.invoke(fi)
        case let fi as Kind<F, Void>:
            return f.invoke(fi)
        default:
            fatalError()
        }
    }
}
