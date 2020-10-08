@testable import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Trampoline: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Trampoline<A>> {
        Free<Function0Partial, A>.arbitrary.map(Trampoline.init)
    }
}

// MARK: Instance of ArbitraryK for Function1

extension TrampolinePartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> TrampolineOf<A> {
        Trampoline.arbitrary.generate
    }
}
