import Foundation

public final class ForZipList {}

public typealias ZipListOf<A> = Kind<ForZipList, A>

public final class ZipList<A>: ZipListOf<A> {
    private var sequence: AnySequence<A>

    /// Concatenates two ZipLists
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the concatenation.
    ///   - rhs: Right hand side of the concatenation.
    /// - Returns: A ZipList that contains the elements of the two ZipLists in the order they appear in the original ones.
    public static func +(lhs: ZipList<A>, rhs: ZipList<A>) -> ZipList<A> {
        return ZipList([lhs.sequence, rhs.sequence].joined())
    }

    /// Prepends an element to a ZipList.
    ///
    /// - Parameters:
    ///   - lhs: Element to prepend.
    ///   - rhs: Array.
    /// - Returns: A ZipList containing the prepended element at the head and the other ZipList as the tail.
    public static func +(lhs: A, rhs: ZipList<A>) -> ZipList<A> {
        return ZipList(lhs) + rhs
    }

    /// Appends an element to a ZipList.
    ///
    /// - Parameters:
    ///   - lhs: Array.
    ///   - rhs: Element to append.
    /// - Returns: A ZipLists containing all elements of the first ZipLists and the appended element as the last element.
    public static func +(lhs: ZipList<A>, rhs: A) -> ZipList<A> {
        return lhs + ZipList(rhs)
    }
    /// Initializes a `ZipList`.
    ///
    /// - Parameter array: A Swift array of values.
    public init<S>(_ sequence: S) where S: Sequence, S.Element == A {
        self.sequence = AnySequence(sequence)
    }

    /// Initializes a `ZipList`.
    ///
    /// - Parameter values: A variable number of values.
    public init(_ values: A...) {
        self.sequence = AnySequence(values)
    }

    /// Obtains the wrapped sequence.
    public var asSequence: LazySequence<AnySequence<A>> {
        sequence.lazy
    }

    public static func fix(_ fa: ZipListOf<A>) -> ZipList<A> {
        fa as! ZipList<A>
    }
}

extension ZipList: CustomStringConvertible {
    public var description: String {
        asSequence.flatMap { ["\($0)"] }.joined(separator: ", ")
    }
}

public postfix func ^<A>(_ fa: ZipListOf<A>) -> ZipList<A> {
    ZipList.fix(fa)
}

// MARK: Instance of `Functor` for `ZipList`
extension ForZipList: Functor {
    public static func map<A, B>(_ fa: Kind<ForZipList, A>, _ f: @escaping (A) -> B) -> Kind<ForZipList, B> {
        ZipList(fa^.asSequence.map(f))
    }
}

// MARK: Instance of `Applicative` for `ZipList`
extension ForZipList: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForZipList, A> {
        ZipList(sequence(first: a, next: { _ in a }))
    }

    public static func ap<A, B>(_ ff: Kind<ForZipList, (A) -> B>, _ fa: Kind<ForZipList, A>) -> Kind<ForZipList, B> {
        ZipList(
            Swift.zip(fa^.asSequence, ff^.asSequence).lazy.map(|>)
        )
    }
}

// MARK: Instance of `Foldable`for `ZipList`
extension ForZipList: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForZipList, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        fa^.asSequence.reduce(b, f)
    }

    public static func foldRight<A, B>(_ fa: Kind<ForZipList, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {

        func loop(_ it: AnyIterator<A>) -> Eval<B> {
            if let a = it.next() {
                return .defer { f(a, loop(it)) }
            } else {
                return b
            }
        }

        return loop(fa^.asSequence.makeIterator())
    }
}
