import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension LazyFunction0: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<LazyFunction0<A>> {
        A.arbitrary.map { a in LazyFunction0 { a } }
    }
}

// MARK: Instance of ArbitraryK for Function0

extension LazyFunction0Partial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> LazyFunction0Of<A> {
        LazyFunction0.arbitrary.generate
    }
}
