import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension IxStateT: Arbitrary where F: ArbitraryK & Applicative, SI: CoArbitrary & Hashable, SO: Arbitrary, A: Arbitrary {
    public static var arbitrary: Gen<IxStateT<F, SI, SO, A>> {
        return Gen.from(IxStateTUnary.generate >>> IxStateT.fix)
    }
}

// MARK: Instance of `ArbitraryK` for `StateT`

extension IxStateTUnary: ArbitraryK where F: ArbitraryK & Applicative, SI: CoArbitrary & Hashable, SO: Arbitrary {
    public static func generate<A: Arbitrary>() -> Kind<IxStateTUnary<F, SI, SO>, A> {
        let a = A.arbitrary.generate
        let sf = Function1<SI, SO>.arbitrary.generate
        let f: (SI) -> Kind<F, (SO, A)> = { s in F.pure((sf.invoke(s), a)) }
        return IxStateT(f)
    }
}
