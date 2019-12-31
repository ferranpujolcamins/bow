import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension ZipList: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<ZipList<A>> {
        return Array.arbitrary.map(ZipList.init)
    }
}

// MARK: Instance of `ArbitraryK` for `ZipList`

extension ForZipList: ArbitraryK {
    public static func generate<A: Arbitrary>() -> Kind<ForZipList, A> {
        return ZipList.arbitrary.generate
    }
}
