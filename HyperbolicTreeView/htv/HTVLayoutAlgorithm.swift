//
//  HTVLayoutAlgorithm.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

struct HTVLayoutAlgorithm {
    let base: Double            // base distance from parent to chilld
}

extension HTVLayoutAlgorithm {

    /// Layouts the nodes in the hyperbolic space.
    /// - Parameter node: root of the tree
    func layout(node: HTVNode) {
        layout(node: node, angle: 0.0, width: Double.pi, length: base)
    }

    /// Layout this node in the hyperbolic space.
    /// First set the poInt at the right distance,
    /// then translate by father's coordinates.
    /// Then, compute the right angle and the right width.
    ///
    /// - Parameter node: root of the tree
    /// - Parameter angle:     the angle from the x axis (bold as love)
    /// - Parameter width:     the angular width to divide, / 2
    /// - Parameter length:    the parent-child length
    ///
    func layout(node: HTVNode, angle: Double, width: Double, length: Double) {
        // this node
        layoutOnly(node: node, angle: angle, length: length)
        // descendant
        let (newAngle, newWidth) = newAngleAndWidth(node: node, angle: angle, width: width, length: length)
        let newLength = newLength(node: node)

        var startAngle: Double = newAngle - newWidth
        for child in node.children {
            let percent: Double = child.poincare.weight / node.poincare.globalWeight
            let childWidth: Double = newWidth * percent
            let childAngle: Double = startAngle + childWidth
            layout(node: child, angle: childAngle, width: childWidth, length: newLength)
            startAngle += 2.0 * childWidth
        }
    }

    func layoutOnly(node child: HTVNode, angle: Double, length: Double) {
        guard let parent = child.parent else { return }
        // We first start as if the parent was the origin.
        // We still are in the hyperbolic space.
        let z = HTVComplex(angle: angle) * length
        // Then translate by parent's coordinates
        child.poincare.coordinates = z.translate(parent.poincare.coordinates)
    }

    func newAngleAndWidth(node child: HTVNode, angle: Double, width: Double, length: Double) -> (Double, Double) {
        guard let parent = child.parent else { return (angle, width) }

        // Compute the new starting angle
        // e(i a) = T(z)oT(zp) (e(i angle))
        let a0 = HTVComplex(angle: angle)
        let a1 = a0.translate(parent.poincare.coordinates)
        let a2 = a1.translate(-child.poincare.coordinates)
        let newAngle = a2.arg

        // Compute the new width
        // e(i w) = T(-length) (e(i width))
        // decomposed to do it faster :-)
        let c: Double = cos(width)
        let A: Double = 1 + length * length
        let B: Double = 2 * length
        let newWidth = acos((A * c - B) / (A - B * c))
        return (newAngle, newWidth)
    }

    func newLength(node parent: HTVNode) -> Double {
        let nbrChild = Double(parent.children.count)
        let l1: Double = (0.95 - base)
        let l2: Double = cos((20.0 * Double.pi) / (2.0 * nbrChild + 38.0))
        return base + (l1 * l2)
    }
}
