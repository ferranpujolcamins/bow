import XCTest
import Bow
import BowFree
import BowFreeGenerators
import BowLaws

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

fileprivate func read() -> ReadWrite<String> {
    ReadWrite.liftF(ReadWriteF.read(id))
}

fileprivate func write(content: String) -> ReadWrite<Void> {
    ReadWrite.liftF(ReadWriteF.write(content, ()))
}

fileprivate func program() -> ReadWrite<Void> {
    let name = ReadWrite<String>.var()
    
    return binding(
        |<-write(content: "What's your name?"),
        name <- read(),
        |<-write(content: "Hello \(name.get)!"),
        yield: ()
    )^
}

fileprivate class StateInterpreter: FunctionK<ReadWriteFPartial, StatePartial<([String], [String])>> {
    
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

extension FreePartial: EquatableK where F: Monad & EquatableK {
    public static func eq<A>(
        _ lhs: FreeOf<F, A>,
        _ rhs: FreeOf<F, A>
    ) -> Bool where A: Equatable {
        lhs^.run() == rhs^.run()
    }
}

class FreeTest: XCTestCase {
    func testInterpretsFreeProgram() {
        let state = program().foldMapK(StateInterpreter())^
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
}
