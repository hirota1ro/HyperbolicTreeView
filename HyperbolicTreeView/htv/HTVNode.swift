//
//  HTVNode.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

class HTVNode {
    let name: String

    weak var parent: HTVNode? = nil
    weak var sibling: HTVNode? = nil
    var children: [HTVNode] = []

    var sprite: Sprite? = nil
    var poincare = Poincare()
    var screen = Screen()
    var geodesic: HTVGeodesic? = nil

    init(name: String) { self.name = name }
}

extension HTVNode {

    class Poincare {
        var coordinates: HTVComplex = .zero  // Euclidian coordinates
        var weight: Double = 0.0  // part of space taken by this node
        var globalWeight: Double = 0.0  // sum of children weight
        init() {}
    }

    class Screen {
        var coordinates: HTVComplex = .zero  // current euclidian coordinates
        var oldCoordinates: HTVComplex = .zero  // old euclidian coordinates
        var point: CGPoint = .zero  // current screen coordinates
        init() {}
    }
}

extension HTVNode {

    func add(child: HTVNode) {
        children.append(child)
        child.parent = self
    }

    /// depth first search (preorder)
    /// - Parameter f: callback function
    func traverse(_ f: (HTVNode) -> Void) {
        f(self)
        for child in children {
            child.traverse(f)
        }
    }

    /// depth first search (postorder)
    /// - Parameter f: callback function
    func dfs(_ f: (HTVNode) -> Void) {
        for child in children {
            child.dfs(f)
        }
        f(self)
    }
    
    /// depth first search (postorder), with pruning function
    /// - Parameter f: pruning function (returns true when pruning a branch.)
    /// - Returns: found node, nil otherwise
    func search(_ f: (HTVNode) -> Bool) -> HTVNode? {
        if f(self) {
            return self
        }
        for child in children {
            if let found = child.search(f) {
                return found
            }
        }
        return nil
    }
}

extension HTVNode {

    func balance() {
        poincare.globalWeight = children.reduce(0) { $0 + $1.poincare.weight }
        poincare.weight = poincare.globalWeight > 0 ? 1 + log(poincare.globalWeight) : 1
    }

    func arbitrate() {
        var sibling: HTVNode! = nil
        var first: Bool = true
        var second: Bool = false
        for child in children {
            if first {
                sibling = child
                first = false
                second = true
            } else if second {
                child.sibling = sibling
                sibling.sibling = child
                sibling = child
                second = false
            } else {
                child.sibling = sibling
                sibling = child
            }
        }
    }
}

extension HTVNode {

    /// Translates this node by the given vector.
    /// call from motion tween
    /// - Parameter t: the translation vector
    func translate(_ t: HTVComplex) {
        screen.coordinates = screen.oldCoordinates.translate(t)
        if let parent = self.parent {
            geodesic = HTVGeodesic(from: parent.screen.coordinates, to: screen.coordinates)
        }
    }

    /// Transform this node by the given transformation.
    /// call from mouse drag
    /// - Parameter t: the transformation
    func apply(transform t: HTVTransform) {
        screen.coordinates = t.transform(from: screen.oldCoordinates)
        if let parent = self.parent {
            geodesic = HTVGeodesic(from: parent.screen.coordinates, to: screen.coordinates)
        }
    }

    /// Ends the translation.
    func commit() {
        screen.oldCoordinates = screen.coordinates
    }

    /// Restores the hyperbolic tree to its origin.
    func restore() {
        let z = poincare.coordinates
        screen.coordinates = z
        screen.oldCoordinates = z
        if let parent = self.parent {
            geodesic = HTVGeodesic(from: parent.screen.coordinates, to: screen.coordinates)
        }
    }
}

extension HTVNode.Poincare: CustomStringConvertible {
    var description: String {
        var a: [String] = []
        if coordinates != .zero {
            a.append("coord=\(coordinates)")
        }
        if weight > 0 {
            a.append("weight=\(weight)")
        }
        if globalWeight > 0 {
            a.append("globalWeight=\(globalWeight)")
        }
        return a.joined(separator: " ")
    }
}

extension HTVNode.Screen: CustomStringConvertible {
    var description: String {
        var a: [String] = []
        if coordinates != .zero {
            a.append("coord=\(coordinates)")
        }
        if oldCoordinates != .zero {
            a.append("old=\(oldCoordinates)")
        }
        if point != .zero {
            a.append("point=\(point)")
        }
        return a.joined(separator: " ")
    }
}

extension HTVNode: CustomStringConvertible {
    var description: String {
        var a: [String] = []
        a.append("\(name)")
        let s = poincare.description
        if !s.isEmpty {
            a.append("poincare={\(s)}")
        }
        let t = screen.description
        if !t.isEmpty {
            a.append("screen={\(t)}")
        }
        if let geod = self.geodesic {
            a.append("geod={\(geod)}")
        }
        return a.joined(separator: " ")
    }
}

extension HTVNode {

    var treeDescription: String {
        let a = HTVNode.recursiveDescription(node: self, indent: [])
        return a.joined(separator: "\n")
    }

    static func recursiveDescription(node: HTVNode, indent: [String]) -> [String] {
        var a: [String] = ["\(indent.joined())\(node)"]
        let n = node.children.count - 1
        for (i, child) in node.children.enumerated() {
            let s: String = (i < n) ? "├" : "└"
            let b: [String]
            if let last = indent.last {
                let t: String = (last == "├") ? "│" : " "
                b = indent.dropLast(1) + [t, s]
            } else {
                b = indent + [s]
            }
            a += HTVNode.recursiveDescription(node: child, indent: b)
        }
        return a
    }
}
