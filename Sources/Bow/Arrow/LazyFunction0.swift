import Foundation

/// Witness for the `LazyFunction0<A>` data type. To be used in simulated Higher Kinded Types`.
public final class ForLazyFunction0 {}

/// Partial application of the `LazyFunction0` type constructor, omitting the last parameter.
public typealias LazyFunction0Partial = ForLazyFunction0

/// Higher Kinded Type alias to improve readability of `Kind<LazyFunction0Partial, A>`.
public typealias LazyFunction0Of<A> = Kind<LazyFunction0Partial, A>

/// This data type acts as a wrapper over functions, like `Function0`.
/// As opposed to `Function0`, function composition is stack-safe.
/// This means that no matter how many `LazyFunction1`s you compose with a `LazyFunction0`, calling the composition won't cause a stack overflow.
public final class LazyFunction0<A>: LazyFunction0Of<A> {
    /// `Coyoneda<ForFunction0, A>` is just `(Function0<P>, Function1<P, A>)` for some hidden type `P`.
    /// So essentially a `LazyFunction0` is a `Function0` composed with a `LazyFunction1`.
    private let value: Coyoneda<ForFunction0, A>

    private init(_ value: Coyoneda<ForFunction0, A>) {
        self.value = value
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `LazyFunction0`.
    public static func fix(_ fa: LazyFunction0Of<A>) -> LazyFunction0<A> {
        fa as! LazyFunction0
    }

    /// Constructs a value of `LazyFunction0`.
    ///
    /// - Parameter f: A constant function.
    public convenience init(_ f: @escaping () -> A) {
        self.init(Function0(f))
    }

    /// Constructs a value of `LazyFunction0`.
    ///
    /// - Parameter f: A constant function.
    public init(_ f: Function0<A>) {
        self.value = .liftCoyoneda(f)
    }

    /// Invokes the function.
    ///
    /// - Returns: Value produced by this function.
    public func invoke() -> A {
        value.lower()^.invoke()
    }

    /// Invokes the function.
    ///
    /// - Returns: Value produced by this function.
    public func callAsFunction() -> A {
        invoke()
    }

    /// Concatenates another function.
    ///
    /// - Parameter f: Function to concatenate.
    /// - Returns: Concatenation of the two functions.
    public func andThen<B>(_ f: @escaping (A) -> B) -> LazyFunction0<B> {
        LazyFunction0<B>(value.map(f)^)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to `LazyFunction0`.
public postfix func ^<A>(_ fa: LazyFunction0Of<A>) -> LazyFunction0<A> {
    LazyFunction0.fix(fa)
}

// MARK: Instance of EquatableK for LazyFunction0
//extension LazyFunction0Partial: EquatableK {
//    public static func eq<A: Equatable>(
//        _ lhs: Function0Of<A>,
//        _ rhs: Function0Of<A>) -> Bool {
////        lhs^.extract() == rhs^.extract()
//    }
//}

// MARK: Instance of Functor for Function0
extension LazyFunction0Partial: Functor {
    public static func map<A, B>(
        _ fa: LazyFunction0Of<A>,
        _ f: @escaping (A) -> B) -> LazyFunction0Of<B> {
        fa^.andThen(f)
    }
}

extension LazyFunction0Partial: Applicative {
    public static func pure<A>(_ a: A) -> LazyFunction0Of<A> {
        LazyFunction0(constant(a))
    }
}

extension LazyFunction0Partial: Selective {}

extension LazyFunction0Partial: Monad {
    public static func flatMap<A, B>(_ fa: LazyFunction0Of<A>, _ f: @escaping (A) -> LazyFunction0Of<B>) -> LazyFunction0Of<B> {
        f(fa^.invoke())
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> LazyFunction0Of<Either<A, B>>) -> LazyFunction0Of<B> {
        // We can't use Trampoline here, because Trampoline internally uses LazyFunction0 and that would cause and endless loop of calls to
        // Trampoline.run
        LazyFunction0<B> {
            var a = a
            while true {
                let x = f(a)^.invoke()
                if let b = x.toOption().orNil {
                    return b
                } else {
                    a = x.leftValue
                }
            }
        }
    }
}
