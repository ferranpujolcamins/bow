import Foundation
import Bow

public final class ForProgram {}
public final class ProgramPartial<F>: Kind<ForProgram, F> {}
public typealias ProgramOf<F, A> = Kind<ProgramPartial<F>, A>
public final class Program<F, A>: ProgramOf<F, A> {
    internal init(asFree: Free<CoyonedaPartial<F>, A>) {
        self.asFree = asFree
    }

    let asFree: Free<CoyonedaPartial<F>, A>

    public static func fix(_ fa: ProgramOf<F, A>) -> Program<F, A> {
        return fa as! Program<F, A>
    }

    public static func liftF(_ fa: Kind<F, A>) -> Program<F, A> {
        return fa |> (Coyoneda.liftCoyoneda
                        >>> Free.liftF
                        >>> Program.init)
    }

    public func foldMapK<M: Monad>(_ f: FunctionK<F, M>) -> Kind<M, A> {
        f.liftEvalI().free().invoke(asFree)^.run()
    }
}

public postfix func ^<F, A>(_ fa: ProgramOf<F, A>) -> Program<F, A> {
    return Program.fix(fa)
}

extension ProgramPartial: Functor {
    public static func map<A, B>(_ fa: Kind<ProgramPartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<ProgramPartial<F>, B> {
        fa^.map(f)
    }
}

extension ProgramPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ProgramPartial<F>, A> {
        Program(asFree: Free<CoyonedaPartial<F>, A>.pure(a)^)
    }

    public static func ap<A, B>(_ ff: Kind<ProgramPartial<F>, (A) -> B>, _ fa: Kind<ProgramPartial<F>, A>) -> Kind<ProgramPartial<F>, B> {
        ff^.ap(fa)
    }
}

extension ProgramPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ProgramPartial<F>, A>, _ f: @escaping (A) -> Kind<ProgramPartial<F>, B>) -> Kind<ProgramPartial<F>, B> {
        fa^.flatMap(f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ProgramPartial<F>, Either<A, B>>) -> Kind<ProgramPartial<F>, B> {
        return flatMap(f(a)) { either in
            either.fold({ left in tailRecM(left, f) },
                        { right in pure(right) })
        }
    }
}
