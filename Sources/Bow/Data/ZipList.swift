import Foundation

public final class ForZipList {}

public typealias ZipListOf<A> = Kind<ForZipList, A>

/// ZipLists wraps a (possibly infinite) Swift sequence providing an Applicative
/// instance based on zipping.
///
/// In other words, `ap` applies a list of functions to a list of values
/// component-wise, instead of applying every function to every value like the standard
/// list applicative instance does.
///
/// This means, for instance, that
///
///     ap(ZipList([{ $0 + 1 }, { $0 + 2 }]),
///        ZipList([0, 1])
///     ) == [1, 3]
///
/// while with ArrayK we'd get
///
///     ap(ArrayK([{ $0 + 1 }, { $0 + 2 }]),
///        ArrayK([0, 1])
///     ) == [1, 2, 2, 3]
///
/// `pure(a)` produces the infinite sequence (a, a, a, ...).
///
/// Infinite sequences
/// ==================
///
/// In order for ZipList to be a lawful Applicative instance, we need to allow infinite lists.
/// To see why, consider the applicative Identity law:
///
///     ap(pure(id), v) == v
///
/// `ap` zips the sequence of functions with the sequence of values and then applies each function to its paired value.
/// Thus the Identity law translates to:
///
///     Swift.zip(pure(id), v).map(|>)
///
/// The law must be true for any ZipList `v`, which might hold a sequence of any lengh. Thus, the result of
///
///     Swift.zip(pure(id), v)
///
/// must have the same lenght than `v`, otherwise they cannot be equal.
///
/// Since Swift.zip produces a list as long as the shortest of its arguments, we conclude that `pure(id)` must
/// be a list of infinite lenght, otherwise, there would exist some list longer than `pure(id)` for which the
/// Identity law would fail.
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
    /// - Parameter arrayk: An array of values.
    public init(_ arrayk: ArrayKOf<A>) {
        self.sequence = AnySequence(arrayk^.asArray)
    }

    /// Initializes a `ZipList`.
    ///
    /// - Parameter values: A variable number of values.
    public init(_ values: A...) {
        self.sequence = AnySequence(values)
    }

    /// Obtains the wrapped sequence.
    ///
    /// This sequence needs to be lazy because it can be an infinite sequence.
    public var asSequence: LazySequence<AnySequence<A>> {
        sequence.lazy
    }

    /// Obtains the wrapped sequence converted into an Array.
    ///
    /// - Warning: This operation might never end if the ZipList wraps
    ///            an infinite sequence.
    public var asArrayK: ArrayK<A> {
        ArrayK(Array(sequence))
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
        ZipList(Swift.sequence(first: a, next: { _ in a }))
    }

    public static func ap<A, B>(_ ff: Kind<ForZipList, (A) -> B>, _ fa: Kind<ForZipList, A>) -> Kind<ForZipList, B> {
        ZipList(
            Swift.zip(fa^.asSequence, ff^.asSequence).lazy.map(|>)
        )
    }
}

// MARK: Instance of `Foldable` for `ZipList`
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

// MARK: Instance of `Traverse` for `ZipList`
extension ForZipList: Traverse {
    public static func traverse<G, A, B>(_ fa: Kind<ForZipList, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForZipList, B>> where G : Applicative {

        let x = foldRight(fa, Eval.always({ G.pure(ZipList<B>([])) }),
                          { a, eval in G.map2Eval(f(a), eval, { x, y in ZipList<B>(x) + y }) }).value()
        return G.map(x, { a in a as ZipListOf<B> })
    }
}
