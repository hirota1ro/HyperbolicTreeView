//
//  ClickDetector.swift
//  HyperTree
//

import Cocoa

class ClickDetector {

    private var prev: CGPoint? = nil
    private var distance: CGFloat = 0

    init() {}

    func mouseDown(view: NSView, event: NSEvent) {
        prev = view.convert(event.locationInWindow, from: nil)
        distance = 0
    }

    func mouseDragged(view: NSView, event: NSEvent) {
        if let prev = self.prev {
            let p = view.convert(event.locationInWindow, from: nil)
            distance += hypot(p.x - prev.x, p.y - prev.y)
            self.prev = p
        }
    }

    func mouseUp(view: NSView, event: NSEvent, _ callback: (NSEvent) -> Void) {
        mouseDragged(view: view, event: event)
        if distance < 1 {
            callback(event)
        }
        prev = nil
    }
}
