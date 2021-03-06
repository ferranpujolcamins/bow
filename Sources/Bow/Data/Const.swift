import Foundation

/// Witness for the `Const<A, T>` data type. To be used in simulated Higher Kinded Types.
public final class ForConst {}

/// Partial application of the Const type constructor, omitting the last parameter.
public final class ConstPartial<A>: Kind<ForConst, A> {}

/// Higher Kinded Type alias to improve readability over `Kind<ConstPartial<A>, T>`
public typealias ConstOf<A, T> = Kind<ConstPartial<A>, T>

/// Constant data type. Represents a container of two types, holding a value of the left type that remains constant, regardless of the transformation applied to it.
public final class Const<A, T>: ConstOf<A, T> {
    /// Constant value wrapped in this data type
    public let value: A

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Const.
    public static func fix(_ fa: ConstOf<A, T>) -> Const<A, T> {
        fa as! Const<A, T>
    }
    
    /// Initializes a constant value.
    ///
    /// - Parameter value: Constant value to be wrapped.
    public init(_ value: A) {
        self.value = value
    }
    
    /// Changes the type of the right type argument associated to this constant value.
    ///
    /// - Returns: The same wrapped value, changing the right type argument.
    public func retag<U>() -> Const<A, U> {
        Const<A, U>(value)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Const.
public postfix func ^<A, T>(_ fa: ConstOf<A, T>) -> Const<A, T> {
    Const.fix(fa)
}

// MARK: Conformance to CustomStringConvertible
extension Const: CustomStringConvertible {
    public var description : String {
        "Const(\(value))"
    }
}

// MARK: Conformance to CustomDebugStringConvertible
extension Const: CustomDebugStringConvertible where A: CustomDebugStringConvertible{
    public var debugDescription: String {
        "Const(\(value.debugDescription))"
    }
}

// MARK: Instance of EquatableK for Const
extension ConstPartial: EquatableK where A: Equatable {
    public static func eq<T: Equatable>(
        _ lhs: ConstOf<A, T>,
        _ rhs: ConstOf<A, T>) -> Bool {
        lhs^.value == rhs^.value
    }
}

// MARK: Instance of HashableK for Const
extension ConstPartial: HashableK where A: Hashable {
    public static func hash<T>(_ fa: ConstOf<A, T>, into hasher: inout Hasher) where T: Hashable {
        hasher.combine(fa^.value)
    }
}

// MARK: Instance of Functor for Const
extension ConstPartial: Functor {
    public static func map<C, B>(
        _ fa: ConstOf<A, C>,
        _ f: @escaping (C) -> B) -> ConstOf<A, B> {
        fa^.retag()
    }
}

// MARK: Instance of Applicative for Const
extension ConstPartial: Applicative where A: Monoid {
    public static func pure<C>(_ a: C) -> ConstOf<A, C> {
        Const<A, C>(.empty())
    }

    public static func ap<C, B>(
        _ ff: ConstOf<A, (C) -> B>,
        _ fa: ConstOf<A, C>) -> ConstOf<A, B> {
        ff^.retag().combine(fa^.retag())
    }
}

// MARK: Instance of Foldable for Const
extension ConstPartial: Foldable {
    public static func foldLeft<C, B>(
        _ fa: ConstOf<A, C>,
        _ b: B,
        _ f: @escaping (B, C) -> B) -> B {
        return b
    }

    public static func foldRight<C, B>(
        _ fa: ConstOf<A, C>,
        _ b: Eval<B>,
        _ f: @escaping (C, Eval<B>) -> Eval<B>) -> Eval<B> {
        return b
    }
}

// MARK: Instance of Traverse for Const
extension ConstPartial: Traverse {
    public static func traverse<G: Applicative, C, B>(
        _ fa: ConstOf<A, C>,
        _ f: @escaping (C) -> Kind<G, B>) -> Kind<G, ConstOf<A, B>> {
        G.pure(fa^.retag())
    }
}

// MARK: Instance of FunctorFilter for Const
extension ConstPartial: FunctorFilter {}

// MARK: Instance of TraverseFilter for Const
extension ConstPartial: TraverseFilter {
    public static func traverseFilter<C, B, G: Applicative>(
        _ fa: ConstOf<A, C>,
        _ f: @escaping (C) -> Kind<G, OptionOf<B>>) -> Kind<G, ConstOf<A, B>> {
        G.pure(fa^.retag())
    }

    public static func mapFilter<C, B>(
        _ fa: ConstOf<A, C>,
        _ f: @escaping (C) -> OptionOf<B>) -> ConstOf<A, B> {
        traverseFilter(fa, { a in Id<OptionOf<B>>.pure(f(a)) })^.value
    }
}

// MARK: Instance of Semigroup for Const
extension Const: Semigroup where A: Semigroup {
    public func combine(_ other: Const<A, T>) -> Const<A, T> {
        Const<A, T>(self.value.combine(other.value))
    }
}

// MARK: Instance of Monoid for Const
extension Const: Monoid where A: Monoid {
    public static func empty() -> Const<A, T> {
        Const(A.empty())
    }
}
