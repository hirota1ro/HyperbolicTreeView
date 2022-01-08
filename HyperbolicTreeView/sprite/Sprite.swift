//
//  Sprite.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

protocol SpriteOwner: AnyObject {
    func invalidate(rect: CGRect)
}

class Sprite {
    var point: CGPoint = .zero
    var visible: Bool = true
    var graphics: [Graphics] = []
    weak var parent: SpriteOwner? = nil
    var children: [Sprite] = []

    init() {}

    func add(child: Sprite) {
        children.append(child)
        child.parent = self
        invalidate(rect: child.frame)
    }
    func add(graphics g: Graphics) {
        graphics.append(g)
        invalidate(rect: g.bounds)
    }
    func clearGraphics() {
        let b = bounds
        graphics.removeAll()
        invalidate(rect: b)
    }

    var transform: CGAffineTransform {
        return CGAffineTransform(translationX: point.x, y: point.y)
        // .scaledBy(x: scale.x, y: scale.y)
        // .rotated(by: rotation)
        // .shearedBy(x: shear.x, y: shear.y)
    }

    // (parent coordinate)
    func draw() {
        if visible {
            if let ctx: NSGraphicsContext = .current {
                ctx.saveGraphicsState()
                ctx.cgContext.concatenate(transform)
                paint()
                ctx.restoreGraphicsState()
            }
        }
    }
    // (local coordinate)
    func paint() {
        for g in graphics {
            g.draw()
        }
        for child in children {
            child.draw()
        }
    }

    // (local coordinate)
    var bounds: CGRect {
        var rect: CGRect = .null
        rect = graphics.reduce(rect) { $0.union($1.bounds) }
        rect = children.reduce(rect) { $0.union($1.frame) }
        return rect
    }

    // (parent coordinate)
    var frame: CGRect { return bounds.applying(transform) }
}

extension Sprite: SpriteOwner {
    // (local coordinate)
    func invalidate(rect: CGRect) {
        parent?.invalidate(rect: rect.applying(transform))
    }
}

extension CGPoint {
    var magnitude: CGFloat { return hypot(x, y) }

    static func + (a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x + b.x, y: a.y + b.y) }
    static func - (a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x - b.x, y: a.y - b.y) }

    func distance(to other: CGPoint) -> CGFloat { return (self - other).magnitude }
}
