//
//  HyperbolicTreeView.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

class HyperbolicTreeView: NSView {
    static let PREFERRED_DISTANCE_NODE_AND_CHILD: CGFloat = 0.3

    let rootSprite = Sprite()
    var model: HTVNode! = nil  // model tree
    var action: HTVActionManager? = nil  // action manager
    let click = ClickDetector()

    func build(model: HTVNode) {
        self.model = model

        model.traverse({ (node) in
            if let sprite: Sprite = node.sprite {
                rootSprite.add(child: sprite)
            }
        })
        model.dfs { $0.balance() }
        let layouter = HTVLayoutAlgorithm(base: HyperbolicTreeView.PREFERRED_DISTANCE_NODE_AND_CHILD)
        layouter.layout(node: model)
        model.traverse {
            $0.arbitrate()
            $0.restore()
        }

        self.action = HTVActionManager(handler: self, tree: model)

        modelTreeChanged()
        rootSprite.parent = self
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        rootSprite.draw()
    }

    private var projector: HTVProjector {
        let half = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let proj = HTVProjector(origin: half, max: half)
        //print("proj=\(proj)")
        return proj
    }
}

// Mouse Event
extension HyperbolicTreeView {

    override func mouseDown(with event: NSEvent) {
        click.mouseDown(view: self, event: event)
        action?.mousePressed(HTVEventOnNS(view: self, event: event, projector: projector))
    }

    override func mouseMoved(with event: NSEvent) {
        action?.mouseMoved(HTVEventOnNS(view: self, event: event, projector: projector))
    }

    override func mouseDragged(with event: NSEvent) {
        click.mouseDragged(view: self, event: event)
        action?.mouseDragged(HTVEventOnNS(view: self, event: event, projector: projector))
    }

    override func mouseUp(with event: NSEvent) {
        action?.mouseReleased(HTVEventOnNS(view: self, event: event, projector: projector))
        click.mouseUp(view: self, event: event, mouseClicked)
    }

    private func mouseClicked(with event: NSEvent) {
        action?.mouseClicked(HTVEventOnNS(view: self, event: event, projector: projector))
    }
}

extension HyperbolicTreeView: HTVActionHandler {

    func modelTreeChanged() {
        HTVRenderingAlgorithm().render(model: model, projector: self.projector, to: rootSprite)
    }
}

extension HyperbolicTreeView: SpriteOwner {

    func invalidate(rect unused: CGRect) {
        setNeedsDisplay(bounds)
    }
}
