import Foundation

public final class ForZipList {}

public typealias ZipListOf<A> = Kind<ForZipList, A>

public final class ZipList<A>: ZipListOf<A> {
    private var sequence: AnySequence<A>

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

// MARK: Instance of `Functor` for `ZipArray`
extension ForZipList: Functor {
    public static func map<A, B>(_ fa: Kind<ForZipList, A>, _ f: @escaping (A) -> B) -> Kind<ForZipList, B> {
        ZipList(fa^.asSequence.map(f))
    }
}

// MARK: Instance of `Applicative` for `ZipArray`
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
