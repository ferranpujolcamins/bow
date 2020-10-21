import XCTest
import SwiftCheck
import BowLaws
import Bow


@testable import BowGenerators

class TreeTTest: XCTestCase {

    func testEquatableLaws() {
        EquatableKLaws<TreeTPartial<ForId>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<TreeTPartial<ForId>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<TreeTPartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<TreeTPartial<ForId>>.check()
    }

    func testMonadLaws() {
        MonadLaws<TreeTPartial<ForId>>.check()
    }

    func testMonadTransLaws() {
        MonadTransLaws<TreeTPartial<ForId>>.check()
        MonadTransLaws<TreeTPartial<ForOption>>.check()
    }

    func testFoldableLaws() {
        FoldableLaws<TreeTPartial<ForId>>.check()
    }

    func testFoldableIsDepthFirst() {
        //      0
        //    /   \
        //   1     3
        //  /
        // 2
        let tree = Tree<Int>(root: 0, subForest: [Tree(root: 1, subForest: [Tree(root: 2, subForest: [])]), Tree(root: 3, subForest: [])])
        XCTAssertEqual(tree.foldMap { ArrayK($0).asArray }, [0, 1, 2, 3])
    }

    func testTraverseLaws() {
        TraverseLaws<TreeTPartial<ForId>>.check()
    }
}
