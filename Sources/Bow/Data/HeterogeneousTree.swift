//import Foundation
//
//public final class ForHeterogeneousTree {}
//
//public final class HeterogeneousTreePartial<Child>: Kind<ForHeterogeneousTree, Child> {}
//
//public typealias HeterogeneousTreeOf<Child, Node> = Kind<HeterogeneousTreePartial<Child>, Node>
//
//// A tree where the inner nodes and the leafs can have different types.
//public final class HeterogeneousTree<Child, Node>: HeterogeneousTreeOf<Child, Node> {
//
//    public let asTree: Tree<Writer<ArrayK<Child>, Node>>
//
//    public init(_ tree: Tree<Writer<ArrayK<Child>, Node>>) {
//        self.asTree = tree
//    }
//
//    /// Safe downcast.
//    ///
//    /// - Parameter fa: Value in higher-kind form.
//    /// - Returns: Value cast to Tree.
//    public static func fix(_ fa: HeterogeneousTreeOf<Child, Node>) -> HeterogeneousTree {
//        fa as! HeterogeneousTree
//    }
//
//    public var root: Node {
//        asTree.root.run.1
//    }
//
//    public var nodes: ArrayK<Child> {
//        asTree.root.run.0
//    }
//
//    public var subForest: [HeterogeneousTree<Child, Node>] {
//        asTree.subForest.map(HeterogeneousTree.init)
//    }
//
//    public func appendChildren(_ children: ArrayK<Child>) -> HeterogeneousTree {
//        return .init(Tree(root: Writer(Id((asTree.root.run.0 + children, asTree.root.run.1))), subForest: asTree.subForest))
//    }
//
//    public func appendSubForest(_ subForest: [HeterogeneousTree]) -> HeterogeneousTree {
//        .init(asTree.appendSubForest(subForest.map(\.asTree)))
//    }
//}
//
///// Safe downcast.
/////
///// - Parameter fa: Value in higher-kind form.
///// - Returns: Value cast to HeterogeneousTree.
//public postfix func ^<Child, Node>(_ fa: HeterogeneousTreeOf<Child, Node>) -> HeterogeneousTree<Child, Node> {
//    HeterogeneousTree.fix(fa)
//}
//
//// MARK: Instance of EquatableK for Tree
//extension HeterogeneousTreePartial: EquatableK where Child: Equatable {
//    public static func eq<Node>(_ lhs: HeterogeneousTreeOf<Child, Node>, _ rhs: HeterogeneousTreeOf<Child, Node>) -> Bool where Node : Equatable {
//        lhs^.asTree == rhs^.asTree
//    }
//}
//
//// MARK: Instance of Functor for HeterogeneousTree
//extension HeterogeneousTreePartial: Functor {
//    public static func map<B, C>(
//        _ fa: HeterogeneousTreeOf<Child, B>,
//        _ f: @escaping (B) -> C) -> HeterogeneousTreeOf<Child, C> {
//
//        return HeterogeneousTree<Child, C>(fa^.asTree.map { $0.map(f)^ }^)
//    }
//}
//
//// MARK: Instance of Applicative for HeterogeneousTree
//extension HeterogeneousTreePartial: Applicative {
//    public static func pure<Node>(_ a: Node) -> HeterogeneousTreeOf<Child, Node> {
//        HeterogeneousTree<Child, Node>(.pure(.pure(a)^)^)
//    }
//
//    public static func ap<B, C>(_ ff: HeterogeneousTreeOf<Child, (B) -> C>, _ fa: HeterogeneousTreeOf<Child, B>) -> HeterogeneousTreeOf<Child, C> {
//    }
//}
