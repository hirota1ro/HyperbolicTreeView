//
//  ViewController.swift
//  HTV - Hyperbolic Tree View
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var htv: HyperbolicTreeView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = createRandom()
        // print("\(model.treeDescription)")
        htv.build(model: model)
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        htv.modelTreeChanged()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    private func createSimple() -> HTVNode {
        let parent = HTVNode(name: "parent")
        parent.sprite = label(text: parent.name)

        let child = HTVNode(name: "child")
        child.sprite = label(text: child.name)

        parent.add(child: child)
        return parent
    }

    private func createRandom() -> HTVNode {
        recursiveCreate(level: 0, min: 2, branch: 10, ratio: 0.5, suffix: 0)
    }

    /// 再帰的にツリーを作ります
    /// - Parameters:
    ///   - level: 再帰の深さ
    ///   - min: 枝分かれする最小数(1〜2くらい)
    ///   - branch: 枝分かれする幅(5〜10くらい)
    ///   - ratio: 枝分かれ最大数を減らす係数(1未満)
    ///   - suffix: 添字
    /// - Returns: サブツリーのルートノード
    private func recursiveCreate(level: Int, min: Int, branch: Int, ratio: Float, suffix: Int) -> HTVNode {
        let node = HTVNode(name: "\(code(level))-\(suffix)")
        node.sprite = label(text: node.name)
        let m = min + Int(arc4random_uniform(UInt32(branch)))
        if 0 < m {
            let mm = Int(Float(min) * ratio)
            let bb = Int(Float(branch) * ratio)
            for i in 1...m {
                let child = recursiveCreate(level: level + 1, min: mm, branch: bb, ratio: ratio, suffix: i)
                node.add(child: child)
            }
        }
        return node
    }

    private func code(_ index: Int) -> String {
        let a = ["A", "B", "C", "D", "E", "F", "G", "H"]
        return a[index % a.count]
    }

    /// テキスト表示を作って返します
    /// - Parameter text: 表示用テキスト
    /// - Returns: テキスト表示を含むスプライト
    private func label(text: String) -> Sprite {
        let sprite = Sprite()
        let size = text.size(withAttributes: nil)
        let origin = CGPoint(x: -size.width / 2, y: -size.height / 2)
        let path = NSBezierPath(rect: CGRect(origin: origin, size: size))
        sprite.add(graphics: PathFillGraphics(path: path, color: .white))
        sprite.add(graphics: TextGraphics(text: text, point: origin))
        return sprite
    }
}
