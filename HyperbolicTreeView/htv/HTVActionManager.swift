//
//  HTVActionManager.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

protocol HTVActionHandler: AnyObject {

    func modelTreeChanged()
}

class HTVActionManager {

    private weak var handler: HTVActionHandler!
    private weak var tree: HTVNode!

    private var startCoordinates: HTVComplex = .zero  // starting point of dragging (Euclidian)

    /// Constructor.
    /// - Parameter handler: view
    /// - Parameter tree: model tree
    init(handler: HTVActionHandler, tree: HTVNode) {
        self.handler = handler
        self.tree = tree
    }
}

extension HTVActionManager {

    /// Translates the hyperbolic tree by the given vector.
    /// - Parameters:
    ///   - start: drag source point (Euclidian)
    ///   - end: drag destination point (Euclidian)
    func translate(start: HTVComplex, end: HTVComplex) {
        let old: HTVComplex = tree.screen.oldCoordinates
        let zo = -old
        let zs2 = start.translate(zo)

        let de: Double = end.mag2
        let ds: Double = zs2.mag2
        let t = (end * (1.0 - ds) - zs2 * (1.0 - de)) / (1.0 - de * ds)

        if t.isValid {
            let to = HTVTransform.compose(zo, t)
            //print("# \(zo) \(t) compose -> \(to)")
            tree.traverse { $0.apply(transform: to) }
            handler.modelTreeChanged()
        }
    }
}

// Mouse Adapter
extension HTVActionManager {

    /// Called when a user pressed the mouse button on the hyperbolic tree.
    /// Used to get the starting point of the drag.
    /// - Parameters:
    ///   - event: mouse event
    func mousePressed(_ event: HTVEvent) {
        //print("down \(event)")
        startCoordinates = event.coordinates
    }

    /// Called when a user release the mouse button on the hyperbolic tree.
    /// Used to signal the end of the translation.
    /// - Parameters:
    ///   - event: mouse event
    func mouseReleased(_ event: HTVEvent) {
        //print("up \(event)")
        tree.traverse { $0.commit() }
    }

    /// Called when a used drag the mouse on the hyperbolic tree.
    /// Used to translate the hypertree, thus moving the focus.
    /// - Parameters:
    ///   - event: mouse event
    func mouseDragged(_ event: HTVEvent) {
        //print("drag \(event)")
        if startCoordinates.isValid {
            let endPoint = event.coordinates
            if endPoint.isValid {
                translate(start: startCoordinates, end: endPoint)
            }
        }
    }

    /// Called when the mouse mouve Into the hyperbolic tree.
    /// - Parameters:
    ///   - event: mouse event
    func mouseMoved(_ event: HTVEvent) {
        // Not used here.
    }
}

extension HTVActionManager {

    /// Called when a user clicked on the hyperbolic tree.
    /// Used to put the corresponding node (if any) at the
    /// center of the hyperbolic tree.
    /// - Parameters:
    ///   - event: mouse event
    func mouseClicked(_ event: HTVEvent) {
        if event.shift {
            tree.traverse { $0.restore() }
            handler.modelTreeChanged()
        } else {
            if let node: HTVNode = tree.search({ $0.sprite?.frame.contains(event.point) ?? false }) {
                print("clicked \(node)")
            }
        }
    }
}
