infix operator <- : AssignmentPrecedence
prefix operator |<-

/// Creates a binding expression.
///
/// - Parameters:
///   - bound: Variable to be bound in the expression.
///   - fa: Monadic effect.
/// - Returns: A binding expression.
public func <-<F: Monad, A>(
    _ bound: BoundVar<F, A>,
    _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    BindingExpression(bound, fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 2-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar2(bounds.0, bounds.1),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 3-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar3(bounds.0, bounds.1, bounds.2),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 4-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar4(bounds.0, bounds.1, bounds.2, bounds.3),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 5-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar5(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 6-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E, G>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar6(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 7-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E, G, H>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar7(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 8-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E, G, H, I>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar8(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 9-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E, G, H, I, J>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar9(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7, bounds.8),
        fa)
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 10-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <-<F: Monad, A, B, C, D, E, G, H, I, J, K>(
    _ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>, BoundVar<F, K>),
    _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J, K)>) -> BindingExpression<F> {
    BindingExpression(
        BoundVar10(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7, bounds.8, bounds.9),
        fa)
}

/// Creates a binding expression that discards the produced value.
///
/// - Parameter fa: Monadic effect.
/// - Returns: A binding expression.
public prefix func |<-<F: Monad, A>(_ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    BindingExpression(BoundVar(), fa)
}
