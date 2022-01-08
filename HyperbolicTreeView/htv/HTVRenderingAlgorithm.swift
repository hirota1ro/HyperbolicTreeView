//
//  HTVRenderingAlgorithm.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

struct HTVRenderingAlgorithm {
}

extension HTVRenderingAlgorithm {

    func render(model: HTVNode, projector: HTVProjector, to: Sprite) {
        model.traverse { projection(node: $0, projector: projector) }
        to.clearGraphics()
        model.traverse { draw(node: $0, to: to) }
        model.traverse { update(node: $0) }
    }

    func projection(node: HTVNode, projector: HTVProjector) {
        node.screen.point = projector.toScreen(fromEuclidian: node.screen.coordinates)
        node.geodesic?.projection(with: projector)
    }

    func draw(node: HTVNode, to: Sprite) {
        node.geodesic?.draw(to: to)
    }

    func update(node: HTVNode) {
        if let sprite: Sprite = node.sprite {
            if space(node: node) >= sprite.bounds.height {
                sprite.visible = true  // show
                sprite.point = node.screen.point
            } else {
                sprite.visible = false  // hide
            }
        }
    }

    func space(node: HTVNode) -> CGFloat {
        return node.children.count > 0 ? spaceBranch(node: node) : spaceLeaf(node: node)
    }

    func spaceBranch(node: HTVNode) -> CGFloat {
        let child = node.children[0]
        let pChild: CGPoint = child.screen.point
        let dC: CGFloat = node.screen.point.distance(to: pChild)
        let spaceLeaf: CGFloat = spaceLeaf(node: node)
        if spaceLeaf < 0 {
            return dC
        } else {
            return min(spaceLeaf, dC)
        }
    }

    func spaceLeaf(node: HTVNode) -> CGFloat {
        var dF: CGFloat = -1
        var dB: CGFloat = -1

        if let parent = node.parent {
            let pParent: CGPoint = parent.screen.point
            dF = node.screen.point.distance(to: pParent)
        }
        if let sibling = node.sibling {
            let pSibling: CGPoint = sibling.screen.point
            dB = node.screen.point.distance(to: pSibling)
        }

        // this means that the node is a standalone node
        if (dF < 0) && (dB < 0) {
            return CGFloat.greatestFiniteMagnitude
        } else if dF < 0 {
            return dB
        } else if dB < 0 {
            return dF
        } else {
            return min(dF, dB)
        }
    }
}
