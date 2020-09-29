import Foundation
import Bow

public final class ForCoyoneda {}
public typealias AnyFunc = (AnyObject) -> AnyObject
public final class CoyonedaPartial<F>: Kind<ForCoyoneda, F> {}
public typealias CoyonedaOf<F, A> = Kind<CoyonedaPartial<F>, A>

public class Coyoneda<F, A>: CoyonedaOf<F, A> {
    fileprivate let pivot: Kind<F, Any>
    fileprivate let ks: [AnyFunc]

    public static func apply<P>(_ fp : Kind<F, P>, _ f : @escaping (P) -> A) -> Coyoneda<F, A> {
        return unsafeApply(fp, [f as! AnyFunc])
    }

    public static func unsafeApply<P>(_ fp : Kind<F, P>, _ fs : [AnyFunc]) -> Coyoneda<F, A> {
        return Coyoneda<F, A>(fp, fs)
    }

    public static func fix(_ fa : CoyonedaOf<F, A>) -> Coyoneda<F, A> {
        return fa as! Coyoneda<F, A>
    }

    public init<P>(_ pivot : Kind<F, P>, _ ks : [AnyFunc]) {
        self.pivot = pivot as! Kind<F, Any>
        self.ks = ks
    }

    private func transform<P>() -> (P) -> A {
        return { p in
            let result = self.ks.reduce(p as AnyObject, { current, f in f(current) })
            return result as! A
        }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Coyoneda.
public postfix func ^<F, A>(_ fa: CoyonedaOf<F, A>) -> Coyoneda<F, A> {
    return Coyoneda.fix(fa)
}

public extension Coyoneda where F: Functor {
    func lower() -> Kind<F, A> {
        return F.map(pivot, transform())
    }

    func toYoneda() -> Yoneda<F, A> {
        return YonedaFromCoyoneda<F, A>()
    }
}

private class YonedaFromCoyoneda<F: Functor, A>: Yoneda<F, A> {
    override public func apply<B>(_ f: @escaping (A) -> B) -> Kind<F, B> {
        return Yoneda.fix(self.map(f)).lower()
    }
}

extension CoyonedaPartial: Functor {
    public static func map<A, B>(_ fa: Kind<CoyonedaPartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<CoyonedaPartial<F>, B> {
        let coyoneda = Coyoneda.fix(fa)
        return Coyoneda(coyoneda.pivot, coyoneda.ks + [f as! AnyFunc])
    }
}
