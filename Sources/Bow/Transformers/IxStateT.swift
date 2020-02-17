import Foundation

//newtype IxStateT m si so v = IxStateT { runIxStateT:: si -> m (so,v) }

public final class ForIxStateT {}

public typealias IxStateTUnary<F, SI, SO, A> = Kind<Kind2<>, A>
public typealias IxStateTPartial<F> =  Kind<ForIxStateT, F>
//public final class IxStateTPartial<F>: Kind<ForIxStateT, F> {}

public typealias IxStateTOf<F, SI, SO, A> = Kind3<IxStateTPartial<F>, SI, SO, A>

public final class IxStateT<F, SI, SO, A>: IxStateTOf<F, SI, SO, A> {
    fileprivate let irunF: (SI) -> Kind<F, (SO, A)>

    public static func fix(_ fa: IxStateTOf<F, SI, SO, A>) -> IxStateT<F, SI, SO, A> {
        fa as! IxStateT<F, SI, SO, A>
    }

    public init(_ irunF: @escaping (SI) -> Kind<F, (SO, A)>) {
        self.irunF = irunF
    }
}

public postfix func ^<F, SI, SO, A>(_ fa : IxStateTOf<F, SI, SO, A>) -> IxStateT<F, SI, SO, A> {
    IxStateT.fix(fa)
}

public typealias ForIxState = ForIxStateT

public typealias IxState<SI, SO, A> = IxStateT<ForId, SI, SO, A>

public extension IxStateT where F == ForId {
    convenience init(_ irun: @escaping (SI) -> (SO, A)) {
        self.init { s in Id(irun(s)) }
    }

    func irun(_ initialState: SI) -> (SO, A) {
        Id.fix(self.irunM(initialState)).value
    }

    func irunA(_ s: SI) -> A {
        irun(s).1
    }

    func irunS(_ s: SI) -> SO {
        irun(s).0
    }
}

extension IxStateT where F: Functor {
    public func itransform<SN, B>(_ f: @escaping (SO, A) -> (SN, B)) -> IxStateT<F, SI, SN, B> {
        IxStateT<F, SI, SN, B>(irunF >>> F.lift(f))
    }

    public static func iliftF<S>(_ fa: Kind<F, A>) -> IxStateT<F, S, S, A> {
        IxStateT<F, S, S, A> { s in fa.map { a in (s, a) } }
    }

    public func irunA(_ s: SI) -> Kind<F, A> {
        irunM(s).map{ (_, a) in a }
    }

    public func irunS(_ s: SI) -> Kind<F, SO> {
        irunM(s).map { (s, _) in s }
    }

    public func irunM(_ initial: SI) -> Kind<F, (SO, A)> {
        irunF(initial)
    }

    public func imodifyF(_ f: @escaping (SI) -> Kind<F, SO>) -> IxStateT<F, SI, SO, ()> {
        return IxStateT<F, SI, SO, ()> { si in f(si).map { ss in (ss, ()) } }
    }

    public func isetF(_ fs: Kind<F, SO>) -> IxStateT<F, SI, SO, ()> {
        self.imodifyF { _ in fs }
    }
}

extension IxStateT where F: Monad {
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> IxStateT<F, SI, SO, B> {
        IxStateT<F, SI, SO, B>(
            irunF >>> { fsoa in
                fsoa.flatMap { (so, a) in
                    f(a).map { b in (so, b) }
                }
            }
        )
    }
}

//extension

//extension IxStateTPartial: IxFunctor where F: Functor {
//    public static func imap<SI, SO, A, B>(_ fa: Kind3<IxStateTPartial<F>, SI, SO, A>, _ f: @escaping (A) -> B) -> Kind3<Self, SI, SO, B> {
//        fa^.ma
//    }
//}
