import Foundation

public final class ForTreeTNode {}
public final class TreeTNodePartial<F>: Kind<ForTreeTNode, F> {}
public typealias TreeTNodeOf<F, A> = Kind<TreeTNodePartial<F>, A>
public final class TreeTNode<F, A>: TreeTNodeOf<F, A> {
    let root: A
    let subForest: ArrayK<TreeT<F, A>>

    init(root: A, subForest: ArrayK<TreeT<F, A>>) {
        self.root = root
        self.subForest = subForest
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to Tree.
    public static func fix(_ fa: TreeTNodeOf<F, A>) -> TreeTNode<F, A> {
        fa as! TreeTNode<F, A>
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Tree.
public postfix func ^<F, A>(_ fa: TreeTNodeOf<F, A>) -> TreeTNode<F, A> {
    TreeTNode.fix(fa)
}

extension TreeTNodePartial: Invariant where F: Functor {}

extension TreeTNodePartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: TreeTNodeOf<F, A>, _ f: @escaping (A) -> B) -> TreeTNodeOf<F, B> {
        let y = fa^.subForest.map { s in s.map(f)^ }
        let a = f ||> TreeTPartial<F>.map <| ()
        let z = fa^.subForest
        TreeTNode(root: f(fa^.root), subForest: fa^.subForest.map { s in s.map(f)^ })
    }
}

//extension TreeTNodePartial: Applicative where F: Applicative {
//    public static func pure<A>(_ a: A) -> TreeTNodeOf<F, A> {
//
//    }
//
//    public static func ap<A, B>(_ ff: TreeTNode<F, (A) -> B>, _ fa: TreeTNodeOf<F, A>) -> TreeTNodeOf<F, B> {
//        <#code#>
//    }
//}





/// Partial application of the Tree type constructor, omitting the last parameter.
public typealias TreePartial<A> = TreeTPartial<ForId>

/// Higher Kinded Type alias to improve readability over `Kind<TreePartial, A>`.
public typealias TreeOf<A> = TreeTOf<ForId, A>

/// Tree is a TreeT where the effect is `Id`.
public typealias Tree<A> = TreeT<ForId, A>

/// Witness for the `Tree<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTreeT {}

/// Partial application of the Tree type constructor, omitting the last type parameter.
public final class TreeTPartial<F>: Kind<ForTreeT, F> {}

/// Higher Kinded Type alias to improve readability over `Kind<ForTree, A>`.
public typealias TreeTOf<F, A> = Kind<TreeTPartial<F>, A>

/// `TreeT` represents a non-empty tree that allows node to have an arbitrary number of children.
///
/// The `Foldable` instance walks through the tree in depth-first order.
public final class TreeT<F, A>: TreeTOf<F, A> {
    public let value: Kind<F, TreeTNode<F, A>>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to Tree.
    public static func fix(_ fa: TreeTOf<F, A>) -> TreeT<F, A> {
        fa as! TreeT<F, A>
    }

    public init(value: Kind<F, TreeTNode<F, A>) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Tree.
public postfix func ^<F, A>(_ fa: TreeTOf<F, A>) -> TreeT<F, A> {
    TreeT.fix(fa)
}

extension TreeT where F: Functor {

    /// Initialises a tree.
    ///
    /// - Parameters:
    ///   - root: Root element of the tree.
    ///   - subForest: An array with the sub trees of the root element.
    public convenience init(root: Kind<F, A>, subForest: [TreeT<F, A>]) {
        self.init(value: root.map { Pair($0, subForest) })
    }

    /// Adds a tree as a subtree of `self`.
    ///
    /// The root of `tree` will be place directly under the root of `self`.
    ///
    /// - Parameter tree: The tree to add under `self.root`.
    /// - Returns: A tree with the same elements as self with `tree` added as subtree.
    public func appendSubTree(_ tree: TreeT<F, A>) -> TreeT<F, A> {
        appendSubForest([tree])
    }

    /// Adds a collection of trees as subtrees of `self`.
    ///
    /// The root of each subtree will be place directly under the root of `self`.
    ///
    /// - Parameter subForest: A collection of trees to add under `self.root`
    /// - Returns: A tree with the same elements as self with the trees of `subForest` added as subtrees.
    public func appendSubForest(_ subForest: [TreeT<F, A>]) -> TreeT<F, A> {
        TreeT(value: value.map { pair in
            PairPartial.map(pair, { $0 + subForest })^
        })
    }

    public var root: Kind<F, A> {
        value.map(\.first)
    }

    public var subForest: Kind<F, [TreeT<F, A>]> {
        value.map(\.second)
    }
}

extension TreeTPartial where F: Functor {
    public static func liftF<A>(_ fa: Kind<F, A>) -> Kind<TreeTPartial<F>, A> {
        TreeT(root: fa, subForest: [])
    }
}

//// MARK: Instance of CustomStringConvertibleK for TreeT
//extension TreeTPartial: CustomStringConvertibleK where F: CustomStringConvertibleK {
//    public static func description<A: CustomStringConvertible>(of fa: Kind<TreeTPartial, A>) -> String {
//
//        let rootDescription = F.description(of: fa^.root)
//        let subTreeDescription = F.description(of: fa^.subForest)
//
//        return "\(rootDescription) -<\n\(subTreeDescription)"
//    }
//}

// MARK: Instance of EquatableK for TreeT
extension TreeTPartial: EquatableK where F: EquatableK {
    public static func eq<A>(_ lhs: TreeTOf<F, A>, _ rhs: TreeTOf<F, A>) -> Bool where A : Equatable {
        lhs^.value.eq(rhs^.value)
    }
}

// MARK: Instance of Functor for TreeT
extension TreeTPartial: Invariant where F: Functor {}
extension TreeTPartial: Functor where F: Functor {
    public static func map<A, B>(
        _ fa: TreeTOf<F, A>,
        _ f: @escaping (A) -> B) -> TreeTOf<F, B> {

        fa^.value.map { n in n.map(f)}


//        TreeT<F, B>(value: fa^.value.map { pair in
//            pair.bimap(f, { $0.map { subTree in
//                subTree.map(f)^
//            } })
//        })
    }
}

// MARK: Instance of Applicative for TreeT
extension TreeTPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> TreeTOf<F, A> {
        TreeT(root: F.pure(a), subForest: [])
    }

    public static func ap<A, B>(_ ff: TreeTOf<F, (A) -> B>, _ fa: TreeTOf<F, A>) -> TreeTOf<F, B> {
        let ff = ff^
        let fa = fa^

        /*
                instance Applicative m => Applicative (TreeT m) where
                   pure x = TreeT $ pure (x, [])
                   (TreeT f_arg) <*> (TreeT m_arg) =
                      TreeT $ mk <$> f_arg <*> m_arg
                         where
                            mk (f,fs) (m,ms) = (f m, ch1 ++ ch2)
                               where
                                  ch1 = map (fmap f) ms
                                  ch2 = map (<*> TreeT m_arg) fs
         */










        let e = F.ap(ff.root, fa.root)
        let r = fa.subForest.map { fs in fs.map { ap(ff, $0) } }
        let o = ff.subForest.map { fs in fs.map { ap($0, fa) } }

        return TreeT(root: F.ap(ff.root, fa^.root),
                     subForest: fa^.subForest.map { TreeTPartial.ap(ff, $0)^ } // TODO: is this correct?
                        + ff.subForest.map { TreeTPartial.ap($0, fa)^ })

    }
}
 /*

// MARK: Instance of Selective for TreeT
extension TreeTPartial: Selective where F: Monad & Traverse {}

// MARK: Instance of Monad for Tree
// TODO: can we relax traverse requirement?
extension TreeTPartial: Monad where F: Monad & Traverse {
    public static func flatMap<A, B>(_ fa: TreeTOf<F, A>, _ f: @escaping (A) -> TreeTOf<F, B>) -> TreeTOf<F, B> {
        return stackSafeFlatMap(fa, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> TreeTOf<F, Either<A, B>>) -> TreeTOf<F, B> {
        let f = { f($0)^ }
        return loop(f(a), f).run()
    }

    private static func loop<A, B>(_ a: TreeTOf<F, Either<A, B>>, _ f: @escaping (A) -> TreeTOf<F, Either<A, B>>) -> Trampoline<TreeTOf<F, B>> {
        return .defer {
            let fLiftedToEither: (Either<A, Kind<F, B>>) -> Trampoline<TreeTOf<F, B>> = { e in
                e.fold({ a in
                    loop(f(a), f)
                }) { fb in
                    .done(TreeT(root: fb, subForest: []))
                }
            }

            let rootImageTrampoline = fLiftedToEither(a^.root.sequence()^)
            let subForestImageTrampoline = a^.subForest.traverse { loop($0, f) }^


            return .map(rootImageTrampoline, subForestImageTrampoline) { $0^.appendSubForest($1.map { $0^ }) }^
        }
    }
}

// MARK: Instance of MonadTrans for TreeT
extension TreeTPartial: MonadTrans where F: Monad & Traverse {}

// MARK: Instance of Foldable for TreeT
extension TreeTPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(_ fa: TreeTOf<F, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {

        fa^.subForest.foldLeft(fa^.root.foldLeft(b, f)) { (bPartial, tree) in
            foldLeft(tree, bPartial, f)
        }
    }

    public static func foldRight<A, B>(_ fa: TreeTOf<F, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.subForest.foldRight(fa^.root.foldRight(b, f)) { (tree, bPartial) -> Eval<B> in
            foldRight(tree, bPartial, f)
        }
    }
}

// MARK: Instance of Traverse for Tree
extension TreeTPartial: Traverse where F: Traverse {
    public static func traverse<G, A, B>(_ fa: TreeTOf<F, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, TreeTOf<F, B>> where G : Applicative {
        let liftedRoot = F.traverse(fa^.root, f)
        let liftedSubForest = fa^.subForest.traverse { t in t.traverse(f).map { $0^ } }
        return G.map(liftedRoot, liftedSubForest, TreeT.init)
    }
}

// MARK: Tree function builder
@_functionBuilder
class TreeBuilder {
    public static func buildExpression<F, A>(_ value: Kind<F, A>) -> TreeT<F, A> {
        TreeT(root: value, subForest: [])
    }

    public static func buildExpression<F: Applicative, A>(_ value: A) -> TreeT<F, A> {
        .pure(value)^
    }

    public static func buildExpression<F, A>(_ tree: TreeT<F, A>) -> TreeT<F, A> {
        tree
    }

    public static func buildBlock<F, A>(_ subtrees: TreeT<F, A>...) -> [TreeT<F, A>] {
        subtrees
    }
}
*/

struct File {
    let name: String
    let content: String
}

typealias TreeWithAssociatedData<A, B> = TreeT<PairKPartial<IdPartial, ConstPartial<[B]>>, A>


@_functionBuilder
struct TreeWithAssociatedDataBuilder<A, B> {
    typealias Expression = Either<B, TreeWithAssociatedData<A, B>>
    typealias Block = ([B], [TreeWithAssociatedData<A, B>])
    public static func buildExpression(_ value: B) -> Expression {
        .left(value)
    }

    public static func buildExpression(_ tree: TreeWithAssociatedData<A, B>) -> Expression {
        .right(tree)
    }

    public static func buildBlock(_ expressions: Expression...) -> Block {
        let expressions = ArrayK(expressions)
        let nodes = expressions.mapFilter { Option.fromOptional($0.leftOrNil) }^.asArray
        let trees = expressions.mapFilter { Option.fromOptional($0.orNil) }^.asArray
        return (nodes, trees)
    }
}

infix operator -<

//func -< <A>(_ root: A, @TreeBuilder _ subForest: () -> [Tree<A>]) -> Tree<A> {
//    Tree(root: root, subForest: subForest())
//}
//
//func someTree() -> Tree<Int> {
//    3 -< {
//        4 -< {
//            5
//            7
//            8
//        }
//        5
//        6
//        7
//    }
//}


func -< <A, B>(_ root: A, @TreeWithAssociatedDataBuilder<A, B> _ content: () -> TreeWithAssociatedDataBuilder<A, B>.Block) -> TreeWithAssociatedData<A, B> {
    let content = content()
    return TreeWithAssociatedData(root: PairK(Id(root), Const(content.0)), subForest: content.1)
}


typealias FileSystem = TreeWithAssociatedData<String, File>

func someFileSystem() -> FileSystem {

    "root" -< {
        File(name: "", content: "")
        File(name: "", content: "")
        "subdir" -< {
            File(name: "", content: "")
            File(name: "", content: "")
        }
    }
}
