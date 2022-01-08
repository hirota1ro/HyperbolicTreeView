//
//  Graphics.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

protocol Graphics {
    func draw()
    var bounds: CGRect { get }
}

struct PathStrokeGraphics: Graphics {
    let path: NSBezierPath
    let color: NSColor

    func draw() {
        color.setStroke()
        path.stroke()
    }

    var bounds: CGRect { path.bounds }
}

struct PathFillGraphics: Graphics {
    let path: NSBezierPath
    let color: NSColor

    func draw() {
        color.setFill()
        path.fill()
    }

    var bounds: CGRect { return path.bounds }
}

struct TextGraphics: Graphics {
    let text: String
    let point: NSPoint

    func draw() {
        text.draw(at: point, withAttributes: nil)
    }

    var bounds: CGRect { return CGRect(origin: point, size: text.size(withAttributes: nil)) }
}

struct ImageGraphics: Graphics {
    let image: NSImage
    let rect: CGRect

    func draw() {
        image.draw(in: rect)
    }

    var bounds: CGRect { return rect }
}
