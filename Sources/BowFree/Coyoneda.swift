import Foundation
import Bow

public final class ForCoyonedaF {}
public final class CoyonedaFPartial<F, A>: Kind2<ForCoyonedaF, F, A> {}
public typealias CoyonedaFOf<F, A, P> = Kind<CoyonedaFPartial<F, A>, P>
public final class CoyonedaF<F, A, P>: CoyonedaFOf<F, A, P> {
    init(pivot: Kind<F, P>, f: @escaping (P) -> A) {
        self.pivot = pivot
        self.f = f
    }

    let pivot: Kind<F, P>
    let f: (P) -> A

    static func fix(_ fa: CoyonedaFOf<F, A, P>) -> CoyonedaF<F, A, P> {
        fa as! CoyonedaF<F, A, P>
    }
}

public postfix func ^<F, A, P>(_ fa: CoyonedaFOf<F, A, P>) -> CoyonedaF<F, A, P> {
    CoyonedaF.fix(fa)
}

public final class ForCoyoneda {}
public final class CoyonedaPartial<F>: Kind<ForCoyoneda, F> {}
public typealias CoyonedaOf<F, A> = Kind<CoyonedaPartial<F>, A>

public class Coyoneda<F, A>: CoyonedaOf<F, A> {
    internal let coyonedaF: Exists<CoyonedaFPartial<F, A>>
    
    public init(coyonedaF: Exists<CoyonedaFPartial<F, A>>) {
        self.coyonedaF = coyonedaF
    }

    public convenience init<P>(pivot: Kind<F, P>, f: @escaping (P) -> A) {
        self.init(coyonedaF: Exists(CoyonedaF(pivot: pivot, f: f)))
    }
    
    public static func fix(_ fa: CoyonedaOf<F, A>) -> Coyoneda<F, A> {
        fa as! Coyoneda<F, A>
    }
}

extension Coyoneda {
    public static func liftCoyoneda(_ fa: Kind<F, A>) -> Coyoneda<F, A> {
        Coyoneda<F, A>(pivot: fa, f: id)
    }
}

extension Coyoneda where F: Functor {
    public func lower() -> Kind<F, A> {
        coyonedaF.run(Lower())
    }

    private class Lower<F: Functor, A>: CokleisliK<CoyonedaFPartial<F, A>, Kind<F, A>> {
        public override func invoke<T>(_ fa: CoyonedaFOf<F, A, T>) -> Kind<F, A> {
            fa^.pivot.map(fa^.f)
        }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Coyoneda.
public postfix func ^<F, A>(_ fa: CoyonedaOf<F, A>) -> Coyoneda<F, A> {
    Coyoneda.fix(fa)
}

// MARK: Instance of Functor for Coyoneda

extension CoyonedaPartial: Functor {
    public static func map<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> B
    ) -> CoyonedaOf<F, B> {
        fa^.coyonedaF.run(Map(f: f))
    }

    private class Map<F, A, B>: CokleisliK<CoyonedaFPartial<F, A>, CoyonedaOf<F, B>> {
        internal init(f: @escaping (A) -> B) {
            self.f = f
        }

        let f: (A) -> B

        override func invoke<T>(_ fa: CoyonedaFOf<F, A, T>) -> CoyonedaOf<F, B> {
            Coyoneda(pivot: fa^.pivot, f: f <<< fa^.f)
        }
    }
}

// MARK: Instance of Applicative for Coyoneda

extension CoyonedaPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> CoyonedaOf<F, A> {
        Coyoneda.liftCoyoneda(F.pure(a))
    }
    
    public static func ap<A, B>(
        _ ff: CoyonedaOf<F, (A) -> B>,
        _ fa: CoyonedaOf<F, A>
    ) -> CoyonedaOf<F, B> {
        Coyoneda.liftCoyoneda(
            F.ap(ff^.lower(), fa^.lower())
        )
    }
}

// MARK: Instance of Selective for Coyoneda

extension CoyonedaPartial: Selective where F: Monad {}

// MARK: Instance of Monad for Coyoneda

extension CoyonedaPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> CoyonedaOf<F, B>
    ) -> CoyonedaOf<F, B> {
        fa^.coyonedaF.run(FlatMap(f: f))
    }

    private class FlatMap<F: Monad, A, B>: CokleisliK<CoyonedaFPartial<F, A>, CoyonedaOf<F, B>> {
        internal init(f: @escaping (A) -> CoyonedaOf<F, B>) {
            self.f = f
        }

        let f: (A) -> CoyonedaOf<F, B>

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> CoyonedaOf<F, B> {
            Coyoneda.liftCoyoneda(
                F.flatMap(fa^.pivot) { (self.f <<< fa^.f)($0)^.lower() }
            )
        }
    }
    
    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> CoyonedaOf<F, Either<A, B>>
    ) -> CoyonedaOf<F, B> {
        f(a).flatMap { either in
            either.fold(
                { a in tailRecM(a, f) },
                { b in pure(b) }
            )
        }
    }
}

// MARK: Instance of Comonad for Coyoneda

extension CoyonedaPartial: Comonad where F: Comonad {
    public static func coflatMap<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (CoyonedaOf<F, A>) -> B
    ) -> CoyonedaOf<F, B> {
        fa^.coyonedaF.run(CoflatMap(f: f))
    }

    private class CoflatMap<F: Comonad, A, B>: CokleisliK<CoyonedaFPartial<F, A>, CoyonedaOf<F, B>> {
        internal init(f: @escaping (CoyonedaOf<F, A>) -> B) {
            self.f = f
        }

        let f: (CoyonedaOf<F, A>) -> B

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> CoyonedaOf<F, B> {
            Coyoneda.liftCoyoneda(
                fa^.pivot.coflatMap { self.f(Coyoneda(pivot: $0, f: fa^.f)) }
            )
        }
    }
    
    public static func extract<A>(
        _ fa: CoyonedaOf<F, A>
    ) -> A {
        fa^.coyonedaF.run(Extract())
    }

    private class Extract<F: Comonad, A>: CokleisliK<CoyonedaFPartial<F, A>, A> {
        internal override init() {}

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> A {
            fa^.f(fa^.pivot.extract())
        }
    }
}

// MARK: Instance of Foldable for Coyoneda

extension CoyonedaPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ b: B,
        _ f: @escaping (B, A) -> B
    ) -> B {
        fa^.coyonedaF.run(FoldLeft(b: b, f: f))
    }

    private class FoldLeft<F: Foldable, A, B>: CokleisliK<CoyonedaFPartial<F, A>, B> {
        internal init(b: B, f: @escaping (B, A) -> B) {
            self.b = b
            self.f = f
        }

        let b: B
        let f: (B, A) -> B

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> B {
            fa^.pivot.foldLeft(b) { b, t in
                self.f(b, fa^.f(t))
            }
        }
    }
    
    public static func foldRight<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>
    ) -> Eval<B> {
        fa^.coyonedaF.run(FoldRight(b: b, f: f))
    }

    private class FoldRight<F: Foldable, A, B>: CokleisliK<CoyonedaFPartial<F, A>, Eval<B>> {
        internal init(b: Eval<B>, f: @escaping (A, Eval<B>) -> Eval<B>) {
            self.b = b
            self.f = f
        }

        let b: Eval<B>
        let f: (A, Eval<B>) -> Eval<B>

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> Eval<B> {
            fa^.pivot.foldRight(b) { t, b in
                self.f(fa^.f(t), b)
            }
        }
    }
}

// MARK: Instance of Traverse for Coyoneda

extension CoyonedaPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> Kind<G, B>
    ) -> Kind<G, CoyonedaOf<F, B>> {
        fa^.coyonedaF.run(TraverseF(f: f))
    }

    private class TraverseF<F: Traverse, G: Applicative, A, B>: CokleisliK<CoyonedaFPartial<F, A>, Kind<G, CoyonedaOf<F, B>>> {
        internal init(f: @escaping (A) -> Kind<G, B>) {
            self.f = f
        }

        let f: (A) -> Kind<G, B>

        override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> Kind<G, CoyonedaOf<F, B>> {
            fa^.pivot.traverse(f <<< fa^.f)
                .map(Coyoneda.liftCoyoneda)
        }
    }
}
