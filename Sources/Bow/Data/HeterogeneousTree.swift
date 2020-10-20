import Foundation

public final class ForHeterogeneousTree {}

public final class HeterogeneousTreePartial<Child>: Kind<ForHeterogeneousTree, Child> {}

public typealias HeterogeneousTreeOf<Child, Node> = Kind<HeterogeneousTreePartial<Child>, Node>

// A tree where the inner nodes and the leafs can have different types.
public final class HeterogeneousTree<Child, Node>: HeterogeneousTreeOf<Child, Node> {

    public let asTree: Tree<Writer<[Child], Node>>

    public init(_ tree: Tree<Writer<[Child], Node>>) {
        self.asTree = tree
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to Tree.
    public static func fix(_ fa: HeterogeneousTreeOf<Child, Node>) -> HeterogeneousTree {
        fa as! HeterogeneousTree
    }

    public var root: Node {
        asTree.root.run.1
    }

    public var nodes: [Child] {
        asTree.root.run.0
    }

    public var subForest: [HeterogeneousTree<Child, Node>] {
        asTree.subForest.map(HeterogeneousTree.init)
    }

    public func appendChildren(_ children: [Child]) -> HeterogeneousTree {
        .init(Tree(root: Writer(asTree.root.run.1, asTree.root.run.0 + children), subForest: asTree.subForest))
    }

    public func appendSubForest(_ subForest: [HeterogeneousTree]) -> HeterogeneousTree {
        .init(asTree.appendSubForest(subForest.map(\.asTree)))
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to HeterogeneousTree.
public postfix func ^<Child, Node>(_ fa: HeterogeneousTreeOf<Child, Node>) -> HeterogeneousTree<Child, Node> {
    HeterogeneousTree.fix(fa)
}

// MARK: Instance of EquatableK for Tree
extension HeterogeneousTreePartial: EquatableK where Child: Equatable {
    public static func eq<Child, Node>(_ lhs: HeterogeneousTreeOf<Child, Node>, _ rhs: HeterogeneousTreeOf<Child, Node>) -> Bool where Node : Equatable {
        lhs^.asTree == rhs^.asTree
    }
}
