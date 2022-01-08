//
//  TestView.swift
//  HyperbolicTreeViewTests
//

import Foundation

@testable import HyperbolicTreeView

class TestView {
    var action: HTVActionManager? = nil

    init() {
    }
}

extension TestView {

    func mouseDown(_ event: HTVEvent) {
        action?.mousePressed(event)
    }

    func mouseDragged(_ event: HTVEvent) {
        action?.mouseDragged(event)
    }

    func mouseUp(_ event: HTVEvent) {
        action?.mouseReleased(event)
    }
}

extension TestView: HTVActionHandler {

    func modelTreeChanged() {}
}

struct TestEvent: HTVEvent {
    let shift: Bool
    let point: CGPoint
    let coordinates: HTVComplex
}
