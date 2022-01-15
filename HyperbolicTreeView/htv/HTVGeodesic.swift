//
//  HTVGeodesic.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

/// A geodesic linking to points in the Poincare model.
class HTVGeodesic {

    private static let EPSILON: Double = 1.0E-10  // ε

    private static let LINE_COLOR = NSColor(white: 0, alpha: 0.5)

    enum GeodesicType {
        case LINE
        case CURVE
    }

    private var type: GeodesicType = .LINE  // type of the geodesic

    private var a: HTVComplex = .zero  // first point (Euclidian)
    private var b: HTVComplex = .zero  // second point (Euclidian)
    private var c: HTVComplex = .zero  // control point (Euclidian)

    private var sa: CGPoint = .zero  // first point (on the screen)
    private var sb: CGPoint = .zero  // second point (on the screen)
    private var sc: CGPoint = .zero  // control point (on the screen)

    /// Builds the geodesic.
    /// - Parameters:
    ///   - a: start point (Euclidian)
    ///   - b: end point (Euclidian)
    init(from a: HTVComplex, to b: HTVComplex) {
        self.a = a
        self.b = b
        if isOnTheDiameter {
            type = .LINE
        } else {
            type = .CURVE
            self.c = controlPoint(origin: center)
        }
    }

    // Point A,B is on the diameter of the Poincare disk
    var isOnTheDiameter: Bool {
        return (abs(a.magnitude) < HTVGeodesic.EPSILON)  // a == origin
            || (abs(b.magnitude) < HTVGeodesic.EPSILON)  // b == origin
            || (abs(a.re * b.im - a.im * b.re) < HTVGeodesic.EPSILON) // a = lambda.b
    }

    // center of the geodesic
    var center: HTVComplex {
        let da: Double = 1 + a.re * a.re + a.im * a.im
        let db: Double = 1 + b.re * b.re + b.im * b.im
        let dd: Double = 2 * (a.re * b.im - b.re * a.im)
        return HTVComplex(re: b.im * da - a.im * db, im: a.re * db - b.re * da) / dd
    }

    // control point
    func controlPoint(origin zo: HTVComplex) -> HTVComplex {
        let det: Double = (b.re - zo.re) * (a.im - zo.im) - (a.re - zo.re) * (b.im - zo.im)
        let fa: Double = a.im * (a.im - zo.im) - a.re * (zo.re - a.re)
        let fb: Double = b.im * (b.im - zo.im) - b.re * (zo.re - b.re)
        let z1 = HTVComplex(re: a.im - zo.im, im: zo.re - a.re) * fb
        let z2 = HTVComplex(re: b.im - zo.im, im: zo.re - b.re) * fa
        return (z1 - z2) / det
    }

    /// Refresh the screen coordinates of this node.
    /// - Parameter projector: converter from Euclidian to Screen
    func projection(with projector: HTVProjector) {
        sa = projector.toScreen(fromEuclidian: a)
        sb = projector.toScreen(fromEuclidian: b)
        sc = projector.toScreen(fromEuclidian: c)
    }

    /// Draws this geodesic.
    /// - Parameter to: drawing target sprite
    func draw(to: Sprite) {
        to.add(graphics: PathStrokeGraphics(path: path, color: HTVGeodesic.LINE_COLOR))
    }

    private var path: NSBezierPath {
        let path = NSBezierPath()
        switch type {
        case .LINE:
            path.move(to: sa)
            path.line(to: sb)
        case .CURVE:
            path.move(to: sa)
            path.curve(to: sb, controlPoint1: sc, controlPoint2: sc)
        }
        return path
    }
}

extension HTVGeodesic: CustomStringConvertible {

    /// Returns a string representation of the object.
    var description: String {
        switch type {
        case .LINE:
            return "LINE from=\(a) to=\(b)"
        case .CURVE:
            return "CURVE from=\(a) control=\(c) to=\(b)"
        }
    }
}
