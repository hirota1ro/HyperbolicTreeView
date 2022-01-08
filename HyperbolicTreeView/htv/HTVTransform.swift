//
//  HTVTransform.swift
//  HTV - Hyperbolic Tree View
//

import Foundation

/// An isometrie transformation in the hyperbolic space.
struct HTVTransform {
    let translation: HTVComplex  // translation vector
    let rotation: HTVComplex  // rotation vector
}

extension HTVTransform {

    // Compose the 2 given vectors translations to a transformation
    // - Returns: the new transformation.
    static func compose(_ first: HTVComplex, _ second: HTVComplex) -> HTVTransform {
        let d = second.conjugate * first + 1
        let r = first.conjugate * second + 1
        return HTVTransform(translation: (first + second) / d, rotation: r / d)
    }

    func transform(from z: HTVComplex) -> HTVComplex {
        let zz = z * rotation + translation
        let d = translation.conjugate * z * rotation + 1
        return zz / d
    }
}

extension HTVTransform: CustomStringConvertible {

    /// Returns a string representation of the object.
    var description: String {
        return "<Transform T=\(translation) R=\(rotation)>"
    }
}
