//
//  HTVProjector.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

struct HTVProjector {
    let origin: CGPoint  // center position (screen coordinate system)
    let max: CGPoint  // max value of width and height (screen coordinate system)
}

extension HTVProjector {

    func toEuclidian(fromScreen s: CGPoint) -> HTVComplex {
        let ex = (s.x - origin.x) / max.x
        let ey = (s.y - origin.y) / max.y
        return HTVComplex(re: ex, im: ey)
    }

    func toScreen(fromEuclidian e: HTVComplex) -> CGPoint {
        let sx = e.re * max.x + origin.x
        let sy = e.im * max.y + origin.y
        return CGPoint(x: sx, y: sy)
    }
}

extension HTVProjector: CustomStringConvertible {

    /// Returns a string representation of the object.
    var description: String { return "<Projector O=\(origin) MAX=\(max)" }
}
