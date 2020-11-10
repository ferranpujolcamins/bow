import Foundation

infix operator |> : AdditionPrecedence
infix operator ||> : AdditionPrecedence

public enum PlaceHolder {
    case __
}

public let __ = PlaceHolder.__

infix operator <| : AdditionPrecedence

public func <|<A, B, C>(_ f: (A, B) -> C, _ value: A) -> (B) -> C {
    { b in f(value, b)}
}

public func <|<A, B, C>(_ f: (A, B) -> C, _ values: (PlaceHolder, B)) -> (A) -> C {
    { a in f(a, values.1)}
}

public func <|<A, B, C>(_ f: (A, B) -> C, _ values: (A, PlaceHolder)) -> (B) -> C {
    { b in f(values.0, b)}
}

func axaxs() {
    let f: (String, Int) -> Int = { s, i in i }

    let p1 = f <| (__, 2) // ()
    let p2 = f <| ("2", __)
    let p2_ = f <| "2"
}

// MARK: - First argument

/// Applies an argument to a 1-ary function.
///
/// - Parameters:
///   - a: Argument to apply.
///   - fun: Function receiving the argument.
/// - Returns: Result of running the function with the argument as input.
public func |><A, B>(_ a: A, _ fun: (A) -> B) -> B {
    fun(a)
}

/// Applies the first argument to a 2-ary function, returning a 1-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C>(_ a: A, _ fun: @escaping (A, B) -> C) -> (B) -> C {
    { b in fun(a,b) }
}

/// Applies the first argument to a 3-ary function, returning a 2-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D>(_ a: A, _ fun: @escaping (A, B, C) -> D) -> (B, C) -> D {
    { b, c in fun(a, b, c) }
}

/// Applies the first argument to a 4-ary function, returning a 3-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E>(_ a: A, _ fun: @escaping (A, B, C, D) -> E) -> (B, C, D) -> E {
    { b, c, d in fun(a, b, c, d) }
}

/// Applies the first argument to a 5-ary function, returning a 4-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F>(_ a: A, _ fun: @escaping (A, B, C, D, E) -> F) -> (B, C, D, E) -> F {
    { b, c, d, e in fun(a, b, c, d, e) }
}

/// Applies the first argument to a 6-ary function, returning a 5-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G>(_ a: A, _ fun: @escaping (A, B, C, D, E, F) -> G) -> (B, C, D, E, F) -> G {
    { b, c, d, e, f in fun(a, b, c, d, e, f) }
}

/// Applies the first argument to a 7-ary function, returning a 6-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G, H>(_ a: A, _ fun: @escaping (A, B, C, D, E, F, G) -> H) -> (B, C, D, E, F, G) -> H {
    { b, c, d, e, f, g in fun(a, b, c, d, e, f, g) }
}

/// Applies the first argument to a 8-ary function, returning a 7-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the first argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the first argument is fixed to the value of the provided argument.
public func |><A, B, C, D, E, F, G, H, I>(_ a: A, _ fun: @escaping (A, B, C, D, E, F, G, H) -> I) -> (B, C, D, E, F, G, H) -> I {
    { b, c, d, e, f, g, h in fun(a, b, c, d, e, f, g, h) }
}

// MARK: - Second argument

/// Applies the second argument to a 2-ary function, returning a 1-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C>(_ b: B, _ fun: @escaping (A, B) -> C) -> (A) -> C {
    { a in fun(a,b) }
}

/// Applies the second argument to a 3-ary function, returning a 2-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D>(_ b: B, _ fun: @escaping (A, B, C) -> D) -> (A, C) -> D {
    { a, c in fun(a, b, c) }
}

/// Applies the second argument to a 4-ary function, returning a 3-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D, E>(_ b: B, _ fun: @escaping (A, B, C, D) -> E) -> (A, C, D) -> E {
    { a, c, d in fun(a, b, c, d) }
}

/// Applies the second argument to a 5-ary function, returning a 4-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D, E, F>(_ b: B, _ fun: @escaping (A, B, C, D, E) -> F) -> (A, C, D, E) -> F {
    { a, c, d, e in fun(a, b, c, d, e) }
}

/// Applies the second argument to a 6-ary function, returning a 5-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D, E, F, G>(_ b: B, _ fun: @escaping (A, B, C, D, E, F) -> G) -> (A, C, D, E, F) -> G {
    { a, c, d, e, f in fun(a, b, c, d, e, f) }
}

/// Applies the second argument to a 7-ary function, returning a 6-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D, E, F, G, H>(_ b: B, _ fun: @escaping (A, B, C, D, E, F, G) -> H) -> (A, C, D, E, F, G) -> H {
    { a, c, d, e, f, g in fun(a, b, c, d, e, f, g) }
}

/// Applies the second argument to a 8-ary function, returning a 7-ary function with the rest of the arguments of the original function.
///
/// - Parameters:
///   - a: Input to the second argument of the function
///   - fun: Function to be applied.
/// - Returns: A function with the same behavior of the input function where the second argument is fixed to the value of the provided argument.
public func ||><A, B, C, D, E, F, G, H, I>(_ b: B, _ fun: @escaping (A, B, C, D, E, F, G, H) -> I) -> (A, C, D, E, F, G, H) -> I {
    { a, c, d, e, f, g, h in fun(a, b, c, d, e, f, g, h) }
}
