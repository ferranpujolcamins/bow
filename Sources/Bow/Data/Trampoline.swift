/// Witness for the `Trampoline<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTrampoline {}

/// Partial application of the Trampoline type constructor, omitting the last type parameter.
public typealias TrampolinePartial = ForTrampoline

/// Higher Kinded Type alias to improve readability over `Kind<ForTrampoline, A>`
public typealias TrampolineOf<A> = Kind<ForTrampoline, A>

/// The Trampoline type helps us overcome stack safety issues of recursive calls by transforming them into loops.
public final class Trampoline<A>: TrampolineOf<A> {
    // TODO: this can probably also be expressed as Program<Function0Partial, A>
    init(_ value: Free<LazyFunction0Partial, A>) {
        self.value = value
    }

    fileprivate let value: Free<LazyFunction0Partial, A>
    /// Creates a Trampoline that does not need to recurse and provides the final result.
    ///
    /// - Parameter value: Result of the computation.
    /// - Returns: A Trampoline that provides a value and stops recursing.
    public static func done(_ value: A) -> Trampoline<A> {
        Trampoline<A>(Free.pure(value)^)
    }
    
    /// Creates a Trampoline that performs a computation and needs to recurse.
    ///
    /// - Parameter f: Function describing the recursive step.
    /// - Returns: A Trampoline that describes a recursive step.
    public static func `defer`(_ f: @escaping () -> Trampoline<A>) -> Trampoline<A> {
        Trampoline(.free(LazyFunction0({ f().value })))
    }
    
    /// Creates a Trampoline that performs a computation in a moment in the future.
    ///
    /// - Parameter f: Function to compute the value wrapped in this Trampoline.
    /// - Returns: A Trampoline that delays the obtention of a value and stops recursing.
    public static func later(_ f: @escaping () -> A) -> Trampoline<A> {
        Trampoline(.liftF(LazyFunction0(f)))
    }
    
    /// Executes the computations described by this Trampoline by converting it into a loop.
    ///
    /// - Returns: Value resulting from the execution of the Trampoline.
    public final func run() -> A {
        value.run()^.invoke()
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Trampoline.
    public static func fix(_ fa: TrampolineOf<A>) -> Trampoline<A> {
        fa as! Trampoline<A>
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Trampoline.
public postfix func ^<A>(_ fa: TrampolineOf<A>) -> Trampoline<A> {
    Trampoline.fix(fa)
}

// MARK: Instance of Functor for Trampoline
extension TrampolinePartial: Functor {
    public static func map<A, B>(_ fa: TrampolineOf<A>, _ f: @escaping (A) -> B) -> TrampolineOf<B> {
        Trampoline<B>(fa^.value.map(f)^)
    }
}

// MARK: Instance of Applicative for Trampoline
extension TrampolinePartial: Applicative {
    public static func pure<A>(_ a: A) -> TrampolineOf<A> {
        Trampoline.done(a)
    }
}

// MARK: Instance of Selective for Trampoline
extension TrampolinePartial: Selective {}

// MARK: Instance of Monad for Trampoline
extension TrampolinePartial: Monad {
    public static func flatMap<A, B>(_ fa: TrampolineOf<A>, _ f: @escaping (A) -> TrampolineOf<B>) -> TrampolineOf<B> {
        Trampoline<B>(fa^.value.flatMap { f($0)^.value }^)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> TrampolineOf<Either<A, B>>) -> TrampolineOf<B> {
        Trampoline<B>(Free.tailRecM(a, { f($0)^.value })^)
    }
}
