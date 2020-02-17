import XCTest
@testable import BowLaws
import Bow

extension IxStateTUnary: EquatableK where F: EquatableK & Monad, SI == Int, SO == String {
    public static func eq<A: Equatable>(_ lhs: Kind<IxStateTUnary<F, SI, SO>, A>, _ rhs: Kind<IxStateTUnary<F, SI, SO>, A>) -> Bool {
        isEqual(lhs^.irunM(1),
                rhs^.irunM(1))
    }
}

class IxStateTTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<IxStateTUnary<ForId, Int, String>>.check()
    }
}
