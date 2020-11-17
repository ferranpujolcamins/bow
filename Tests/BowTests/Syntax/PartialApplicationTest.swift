import XCTest
import SwiftCheck
import Bow
import BowLaws

class PartialApplicationTest: XCTestCase {

    // MARK: First argument

    func testPartialApplicationOfFirstArgumentOnOneArgumentFunctions() {
        func f(_ a : Int) -> Int {
            return a
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int) in
            let g = a |> f
            return g == f(a)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnTwoArgumentFunctions() {
        func f(_ a : Int, _ b : Int) -> Int {
            return a + b
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int) in
            let g = a |> f
            return g(b) == f(a, b)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnThreeArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int) -> Int {
            return a + b + c
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int) in
            let g = a |> f
            return g(b, c) == f(a, b, c)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnFourArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int) -> Int {
            return a + b + c + d
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int, d : Int) in
            let g = a |> f
            return g(b, c, d) == f(a, b, c, d)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnFiveArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int) -> Int {
            return a + b + c + d + e
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            let g = a |> f
            return g(b, c, d, e) == f(a, b, c, d, e)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnSixArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int) -> Int {
            return a + b + c + d + e + h
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int) in
            let g = a |> f
            return g(b, c, d, e, h) == f(a, b, c, d, e, h)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnSevenArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int, _ i : Int) -> Int {
            return a + b + c + d + e + h + i
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int, i : Int) in
            let g = a |> f
            return g(b, c, d, e, h, i) == f(a, b, c, d, e, h, i)
        }
    }
    
    func testPartialApplicationOfFirstArgumentOnEightArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int, _ i : Int, _ j : Int) -> Int {
            return a + b + c + d + e + h + i + j
        }
        
        property("Partially applies the first argument") <~ forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int, i : Int, j : Int) in
            let g = a |> f
            return g(b, c, d, e, h, i, j) == f(a, b, c, d, e, h, i, j)
        }
    }
