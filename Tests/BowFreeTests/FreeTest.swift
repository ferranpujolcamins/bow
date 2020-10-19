import XCTest
import Bow
import BowFree
import BowFreeGenerators
import BowLaws

// MARK: ReadWrite test algebra
fileprivate final class ForReadWriteF {}
fileprivate typealias ReadWriteFPartial = ForReadWriteF
fileprivate typealias ReadWriteFOf<A> = Kind<ForReadWriteF, A>

fileprivate class ReadWriteF<A>: ReadWriteFOf<A> {
    enum _ReadWriteF {
        case read((String) -> A)
        case write(String, A)
    }
    
    let value: _ReadWriteF
    
    private init(_ value: _ReadWriteF) {
        self.value = value
    }

    static func read(_ callback: @escaping (String) -> A) -> ReadWriteF<A> {
        ReadWriteF(.read(callback))
    }
    
    static func write(_ content: String, _ next: A) -> ReadWriteF<A> {
        ReadWriteF(.write(content, next))
    }
}

fileprivate postfix func ^<A>(_ value: ReadWriteFOf<A>) -> ReadWriteF<A> {
    value as! ReadWriteF<A>
}

extension ReadWriteFPartial: Functor {
    static func map<A, B>(
        _ fa: ReadWriteFOf<A>,
        _ f: @escaping (A) -> B
    ) -> ReadWriteFOf<B> {
        switch fa^.value {
        
        case .read(let callback):
            return ReadWriteF.read(callback >>> f)
        case .write(let content, let next):
            return ReadWriteF.write(content, f(next))
        }
    }
}

fileprivate typealias ReadWrite<A> = Free<ReadWriteFPartial, A>

extension ReadWriteFPartial {
    static fileprivate func read() -> ReadWrite<String> {
        ReadWrite.liftF(ReadWriteF.read(id))
    }

    static fileprivate func write(content: String) -> ReadWrite<Void> {
        ReadWrite.liftF(ReadWriteF.write(content, ()))
    }
}

fileprivate func readWriteProgram() -> ReadWrite<Void> {
    let name = ReadWrite<String>.var()
    
    return binding(
        |<-ReadWriteFPartial.write(content: "What's your name?"),
        name <- ReadWriteFPartial.read(),
        |<-ReadWriteFPartial.write(content: "Hello \(name.get)!"),
        yield: ()
    )^
}

fileprivate class ReadWriteStateInterpreter: FunctionK<ReadWriteFPartial, StatePartial<([String], [String])>> {
    
    override func invoke<A>(
        _ fa: ReadWriteFOf<A>
    ) -> StateOf<([String], [String]), A> {
        switch fa^.value {
        
        case .read(let callback):
            return State { state -> (([String], [String]), A) in
                let input = state.0[0]
                let remaining = Array(state.0.dropFirst())
                return ((remaining, state.1), callback(input))
            }
            
        case .write(let content, let next):
            return State { state -> (([String], [String]), A) in
                let outputs = state.1 + [content]
                return ((state.0, outputs), next)
            }
        }
    }
}

// MARK: - Arithmetic test algebra
fileprivate final class ForArithmeticF {}
fileprivate typealias ArithmeticFPartial = ForArithmeticF
fileprivate typealias ArithmeticFOf<A> = Kind<ForArithmeticF, A>

fileprivate class ArithmeticF<A>: ArithmeticFOf<A> {
    enum _ArithmeticF {
        case value(A)
        case add(A, A)
    }

    let value: _ArithmeticF

    private init(_ value: _ArithmeticF) {
        self.value = value
    }

    static func value(_ v: A) -> ArithmeticF<A> {
        ArithmeticF(.value(v))
    }

    static func add(_ v1: A, _ v2: A) -> ArithmeticF<A> {
        ArithmeticF(.add(v1, v2))
    }
}

fileprivate postfix func ^<A>(_ value: ArithmeticFOf<A>) -> ArithmeticF<A> {
    value as! ArithmeticF<A>
}

extension ArithmeticFPartial: Functor {
    static func map<A, B>(
        _ fa: ArithmeticFOf<A>,
        _ f: @escaping (A) -> B
    ) -> ArithmeticFOf<B> {
        switch fa^.value {
        case .value(let v):
            return ArithmeticF.value(f(v))
        case .add(let v1, let v2):
            return ArithmeticF.add(f(v1), f(v2))
        }
    }
}

fileprivate typealias Arithmetic<A> = Free<ArithmeticFPartial, A>

extension ArithmeticFPartial {
    static fileprivate func value<A>(_ v: A) -> Arithmetic<A> {
        Arithmetic.liftF(ArithmeticF.value(v))
    }

    static fileprivate func add<A>(_ v1: A, _ v2: A) -> Arithmetic<A> {
        Arithmetic.liftF(ArithmeticF.add(v1, v2))
    }
}

fileprivate func arithmeticProgram(_ n: Int, _ stopAt: Int) -> Arithmetic<Int> {
    let val = Arithmetic<Int>.var()
    let result = Arithmetic<Int>.var()

    return binding(
        val <- ArithmeticFPartial.add(n, 1),
        result <- (val.get < stopAt)
            ? arithmeticProgram(val.get, stopAt)
            : Arithmetic<Int>.pure(val.get),
        yield: result.get
    )^
}

fileprivate class ArithmeticArrayInterpreter: FunctionK<ArithmeticFPartial, ArrayKPartial> {

    override func invoke<A>(
        _ fa: ArithmeticFOf<A>
    ) -> ArrayKOf<A> {
        switch fa^.value {
        case .value(let v):
            return ArrayK.pure(v)
        case .add(let v1, let v2):
            return ArrayK([v1, v2])
        }
    }
}

// MARK: - Free tests

extension FreePartial: EquatableK where F: Monad & EquatableK {
    public static func eq<A>(
        _ lhs: FreeOf<F, A>,
        _ rhs: FreeOf<F, A>
    ) -> Bool where A: Equatable {
        lhs^.run() == rhs^.run()
    }
}

class FreeTest: XCTestCase {
    func testInterpretsFreereadWriteProgram() {
        let state = readWriteProgram().foldMapK(ReadWriteStateInterpreter())^
        let final = state.runS((["Bow"], []))
        let outputs = ["What's your name?", "Hello Bow!"]
        XCTAssertEqual(final.0, [String]())
        XCTAssertEqual(final.1, outputs)
    }
    
    func testFunctorLaws() {
        FunctorLaws<FreePartial<ForId>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<FreePartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<FreePartial<ForId>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<FreePartial<ForId>>.check()
    }

    func testFoldMapIsStackSafe() {
        let n = 50000
        let result = arithmeticProgram(0, n)
            .foldMapK(ArithmeticArrayInterpreter())^
            .fold()
        XCTAssertEqual(result, n)
    }
}
