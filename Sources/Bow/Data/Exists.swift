import Foundation

public final class Exists<F> {
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = fa
    }
    let fa: Any

    // (∀X. F<X> -> R) -> R
    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        switch fa {
        case let fi as Kind<F, Int>:
            return f.invoke(fi)
        default:
            fatalError()
        }
    }
}

// A function F<A> -> B that is polymorphic on A, where F and B are fixed
open class CokleisliK<F, B> {
    public init() {}
    open func invoke<A>(_ fa: Kind<F, A>) -> B {
        fatalError("FunctionK.invoke must be implemented in subclasses")
    }
}

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


public final class For_Coyoneda {}
public final class _CoyonedaPartial<F>: Kind<For_Coyoneda, F> {}
public typealias _CoyonedaOf<F, A> = Kind<_CoyonedaPartial<F>, A>

public class _Coyoneda<F, A>: _CoyonedaOf<F, A> {
    init(coyonedaF: Exists<CoyonedaFPartial<F, A>>) {
        self.coyonedaF = coyonedaF
    }

    convenience init<P>(pivot: Kind<F, P>, f: @escaping (P) -> A) {
        self.init(coyonedaF: Exists(CoyonedaF(pivot: pivot, f: f)))
    }

    let coyonedaF: Exists<CoyonedaFPartial<F, A>>

    static func fix(_ fa: _CoyonedaOf<F, A>) -> _Coyoneda<F, A> {
        fa as! _Coyoneda<F, A>
    }
}

public postfix func ^<F, A>(_ fa: _CoyonedaOf<F, A>) -> _Coyoneda<F, A> {
    _Coyoneda.fix(fa)
}

extension _Coyoneda {
    static func liftCoyoneda(_ fa: Kind<F, A>) -> _Coyoneda<F, A> {
        _Coyoneda<F, A>(pivot: fa, f: id)
    }
}

extension _Coyoneda where F: Functor {
    func lower() -> Kind<F, A> {
        coyonedaF.run(Lower())
    }
}

class Lower<F: Functor, A>: CokleisliK<CoyonedaFPartial<F, A>, Kind<F, A>> {
    override func invoke<T>(_ fa: CoyonedaFOf<F, A, T>) -> Kind<F, A> {
        fa^.pivot.map(fa^.f)
    }
}

extension _CoyonedaPartial: Functor {
    public static func map<A, B>(_ fa: _CoyonedaOf<F, A>, _ f: @escaping (A) -> B) -> _CoyonedaOf<F, B> {
        fa^.coyonedaF.run(Map(f: f))
    }
}

class Map<F, A, B>: CokleisliK<CoyonedaFPartial<F, A>, _CoyonedaOf<F, B>> {
    internal init(f: @escaping (A) -> B) {
        self.f = f
    }

    let f: (A) -> B

    override func invoke<T>(_ fa: CoyonedaFOf<F, A, T>) -> _CoyonedaOf<F, B> {
        _Coyoneda(pivot: fa^.pivot, f: f <<< fa^.f)
    }
}

extension _CoyonedaPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> _CoyonedaOf<F, A> {
        a |> (F.pure >>> _Coyoneda.liftCoyoneda)
    }

    public static func ap<A, B>(_ ff: _CoyonedaOf<F, (A) -> B>, _ fa: _CoyonedaOf<F, A>) -> _CoyonedaOf<F, B> {
        _Coyoneda.liftCoyoneda(
            F.ap(ff^.lower(), fa^.lower())
        )
    }
}

extension _CoyonedaPartial: Selective where F: Monad {}

extension _CoyonedaPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: _CoyonedaOf<F, A>,
        _ f: @escaping (A) -> _CoyonedaOf<F, B>
    ) -> _CoyonedaOf<F, B> {
        fa^.coyonedaF.run(FlatMap(f: f))
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> _CoyonedaOf<F, Either<A, B>>) -> _CoyonedaOf<F, B> {
        f(a).flatMap { either in
            either.fold(
                { a in tailRecM(a, f) },
                { b in pure(b) }
            )
        }
    }
}

class FlatMap<F: Monad, A, B>: CokleisliK<CoyonedaFPartial<F, A>, _CoyonedaOf<F, B>> {
    internal init(f: @escaping (A) -> _CoyonedaOf<F, B>) {
        self.f = f
    }

    let f: (A) -> _CoyonedaOf<F, B>

    override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> _CoyonedaOf<F, B> {
        _Coyoneda.liftCoyoneda(
            F.flatMap(fa^.pivot) { (self.f <<< fa^.f)($0)^.lower() }
        )
    }
}

class TailRecM<F: Monad, A, B>: CokleisliK<CoyonedaFPartial<F, A>, _CoyonedaOf<F, B>> {
    internal init(f: @escaping (A) -> _CoyonedaOf<F, B>) {
        self.f = f
    }

    let f: (A) -> _CoyonedaOf<F, B>

    override func invoke<T>(_ fa: Kind<CoyonedaFPartial<F, A>, T>) -> _CoyonedaOf<F, B> {
        _Coyoneda.liftCoyoneda(
            F.flatMap(fa^.pivot) { (self.f <<< fa^.f)($0)^.lower() }
        )
    }
}
