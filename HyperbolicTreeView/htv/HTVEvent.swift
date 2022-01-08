//
//  HTVEvent.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

protocol HTVEvent {
    var shift: Bool { get }
    var point: CGPoint { get }
    var coordinates: HTVComplex { get }
}

struct HTVEventOnNS {
    let view: NSView
    let event: NSEvent
    let projector: HTVProjector
}

extension HTVEventOnNS: HTVEvent {

    /// Returns true when the shift key is pressed.
    var shift: Bool { return event.modifierFlags.contains(.shift) }

    /// Returns the mouse position. (View coordinate system)
    var point: CGPoint { return view.convert(event.locationInWindow, from: nil) }

    /// Returns the mouse position. (Euclidian coordinate system)
    var coordinates: HTVComplex { return projector.toEuclidian(fromScreen: point) }
}

extension HTVEventOnNS: CustomStringConvertible {

    /// Returns a string representation of the object.
    var description: String { return "<HTVEventOnNS point=\(point) cood=\(coordinates)>" }
}
