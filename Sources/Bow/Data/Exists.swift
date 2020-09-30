import Foundation

public final class Exists<F> {
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = fa
    }
    let fa: Any

    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        switch fa {
        case let fi as Kind<F, Int>:
            return f.invoke(fi)
        default:
            fatalError()
        }
    }
}

// A function F<A> -> B that is polymorphic on A, where F and B are fixed
open class CokleisliK<F, B> {
    public init() {}
    open func invoke<A>(_ fa: Kind<F, A>) -> B {
        fatalError("FunctionK.invoke must be implemented in subclasses")
    }
}


public final class ExistsPair<F, R> {
    public init<A>(_ fa: Kind<F, A>, _ f: (A) -> R) {
        self.fa = fa
    }
    let fa: Any
    let f:

    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        switch fa {
        case let fi as Kind<F, Int>:
            return f.invoke(fi)
        default:
            fatalError()
        }
    }
}
