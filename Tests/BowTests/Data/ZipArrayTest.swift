import XCTest
import SwiftCheck
import BowLaws
import Bow

extension ForZipList: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForZipList, A>, _ rhs: Kind<ForZipList, A>) -> Bool where A : Equatable {
        lhs^.asSequence.prefix(100).elementsEqual(rhs^.asSequence.prefix(100))
    }
}

class ZipListTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ForZipList>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForZipList>.check()
    }
}
