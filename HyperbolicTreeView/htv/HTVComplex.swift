//
//  HTVComplex.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

/// Complex Number - used as the coordinates of Euclidean space.
struct HTVComplex {
    var re: Double  // real part
    var im: Double  // imaginary part
}

// Some complex computing formula :
//
// arg(z)  = atan(y / x) if x > 0
//         = atan(y / x) + Pi if x < 0
//
// d(z)    = sqrt((z.x * z.x) + (z.y * z.y))
//
// conj(z) = | z.x
//           | - z.y
//
// a * b   = | (a.x * b.x) - (a.y * b.y)
//           | (a.x * b.y) + (a.y * b.x)
//
// a / b   = | ((a.x * b.x) + (a.y * b.y)) / d(b)^2
//           | ((a.y * b.x) - (a.x * b.y)) / d(b)^2
//
extension HTVComplex {

    /// Returns complex conjugate
    var conjugate: HTVComplex { return HTVComplex(re: re, im: -im) }

    /// Returns the product of two complex numbers.
    /// - Parameter a: the first complex number
    /// - Parameter b: the second complex number
    /// - Returns: new complex number (a * b)
    static func * (a: HTVComplex, b: HTVComplex) -> HTVComplex {
        return HTVComplex(re: (a.re * b.re) - (a.im * b.im), im: (a.re * b.im) + (a.im * b.re))
    }

    /// Returns the value of the first complex number divided by the second complex number.
    /// - Parameter a: the first complex number
    /// - Parameter b: the second complex number
    /// - Returns: new complex number (a / b)
    static func / (a: HTVComplex, b: HTVComplex) -> HTVComplex {
        let d2 = b.mag2
        return HTVComplex(
            re: ((a.re * b.re) + (a.im * b.im)) / d2, im: ((a.im * b.re) - (a.re * b.im)) / d2)
    }

    /// Returns the sum of two complex numbers.
    /// - Parameter a: the first complex number
    /// - Parameter b: the second complex number
    /// - Returns: new complex number (a + b)
    static func + (a: HTVComplex, b: HTVComplex) -> HTVComplex {
        return HTVComplex(re: a.re + b.re, im: a.im + b.im)
    }

    /// Returns the value of the first complex number minus the second complex number.
    /// - Parameter a: the first complex number
    /// - Parameter b: the second complex number
    /// - Returns: new complex number (a - b)
    static func - (a: HTVComplex, b: HTVComplex) -> HTVComplex {
        return HTVComplex(re: a.re - b.re, im: a.im - b.im)
    }

    /// Returns the angle between the x axis and the line
    /// passing throught the origin O and this point.
    /// The angle is given in radians.
    /// arg (z) = arg (x+iy) = atan(y/x)
    /// - Returns: the angle, in radians
    var arg: Double { return atan2(im, re) }

    /// Returns the square of the distance from the origin to this point.
    /// - Returns: the square of the distance
    var mag2: Double { return (re * re) + (im * im) }

    /// Returns the distance from the origin to this point.
    /// - Returns: the distance
    var magnitude: Double { return hypot(re, im) }

    /// Returns the distance from this point to the point given in parameter.
    /// - Parameter other: the other point
    /// - Returns: the distance between the 2 points
    func distance(to: HTVComplex) -> Double { return (to - self).magnitude }
}

// Poincaré disk model
extension HTVComplex {

    /// Are this coordinates in the hyperbolic disc ?
    /// - Returns: true if this point is in, false otherwise
    var isValid: Bool { return mag2 < 1.0 }

    /// Translate this Euclidian point by the coordinates of the given Euclidian point.
    /// - Parameter t: the translation coordinates
    /// - Returns: z' = (z + t) / (1 + z * conj(t))
    func translate(_ t: HTVComplex) -> HTVComplex {
        return (self + t) / (self * t.conjugate + 1)
    }
}

// Utilities
extension HTVComplex {

    init(angle t: Double) { self.init(re: cos(t), im: sin(t)) }

    static let zero = HTVComplex(re: 0, im: 0)

    static func * (z: HTVComplex, s: Double) -> HTVComplex {
        return HTVComplex(re: z.re * s, im: z.im * s)
    }
    static func / (z: HTVComplex, s: Double) -> HTVComplex {
        return HTVComplex(re: z.re / s, im: z.im / s)
    }

    static func + (z: HTVComplex, s: Double) -> HTVComplex {
        return HTVComplex(re: z.re + s, im: z.im)
    }

    static prefix func - (_ z: HTVComplex) -> HTVComplex { return HTVComplex(re: -z.re, im: -z.im) }
}

extension HTVComplex: CustomStringConvertible {

    /// Returns a string representation of the object.
    var description: String { return im < 0 ? "\(re)\(im)i" : "\(re)+\(im)i" }
}

extension HTVComplex: Equatable {

    static var accuracy: Double = 1e-5

    static func == (a: HTVComplex, b: HTVComplex) -> Bool {
        return abs(a.re - b.re) < accuracy && abs(a.im - b.im) < accuracy
    }
}
