//
//  HyperbolicTreeViewTests.swift
//  HyperbolicTreeViewTests
//

import XCTest

@testable import HyperbolicTreeView

class HyperbolicTreeViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Create Test Tree
        let tree = HTVNode(name: "A")
        tree.add(child: HTVNode(name: "B"))

        // Create Test View
        let view = TestView()
        let action = HTVActionManager(handler: view, tree: tree)
        view.action = action

        tree.dfs { $0.balance() }
        let layouter = HTVLayoutAlgorithm(base: HyperbolicTreeView.PREFERRED_DISTANCE_NODE_AND_CHILD)
        layouter.layout(node: tree)
        tree.traverse {
            $0.arbitrate()
            $0.restore()
        }

        let p0 = CGPoint(x: 100, y: 100)
        let projector = HTVProjector(origin: p0, max: p0)
        let renderer = HTVRenderingAlgorithm()
        tree.traverse { renderer.projection(node: $0, projector: projector) }

        // print("#After 1st refresh\n\(tree.treeDescription)")
        let a = tree.search({ $0.name == "A" })!
        let b = tree.search({ $0.name == "B" })!
        // XCTAssertEqual(actual, expected)
        XCTAssertEqual(a.poincare.coordinates, HTVComplex(re: 0, im: 0))
        XCTAssertEqual(b.poincare.coordinates, HTVComplex(re: 0.3, im: 0))
        XCTAssertEqual(a.screen.coordinates, HTVComplex(re: 0, im: 0))
        XCTAssertEqual(b.screen.coordinates, HTVComplex(re: 0.3, im: 0))
        XCTAssertEqual(a.screen.point, CGPoint(x: 100, y: 100))
        XCTAssertEqual(b.screen.point, CGPoint(x: 130, y: 100))

        let p90 = CGPoint(x: 90, y: 90)
        let z90 = projector.toEuclidian(fromScreen: p90)
        let z0 = projector.toEuclidian(fromScreen: p0)

        // Drag Emulation [1]
        view.mouseDown(TestEvent(shift: false, point: p90, coordinates: z90))
        view.mouseDragged(TestEvent(shift: false, point: p0, coordinates: z0))
        view.mouseUp(TestEvent(shift: false, point: p0, coordinates: z0))
        tree.traverse { renderer.projection(node: $0, projector: projector) }
        // print("#After Drag [1]\n\(tree.treeDescription)")
        XCTAssertEqual(a.poincare.coordinates, HTVComplex(re: 0, im: 0))
        XCTAssertEqual(b.poincare.coordinates, HTVComplex(re: 0.3, im: 0))
        XCTAssertEqual(a.screen.coordinates, HTVComplex(re: 0.1, im: 0.1))
        XCTAssertEqual(b.screen.coordinates, HTVComplex(re: 0.3851949519683557, im: 0.108306649086457))
        XCTAssertEqual(a.screen.point.rounded, CGPoint(x: 110, y: 110))
        XCTAssertEqual(b.screen.point.rounded, CGPoint(x: 139, y: 111))

        // Drag Emulation [2]
        view.mouseDown(TestEvent(shift: false, point: p90, coordinates: z90))
        view.mouseDragged(TestEvent(shift: false, point: p0, coordinates: z0))
        view.mouseUp(TestEvent(shift: false, point: p0, coordinates: z0))
        tree.traverse { renderer.projection(node: $0, projector: projector) }
        // print("#After Drag [2]\n\(tree.treeDescription)")
        XCTAssertEqual(a.poincare.coordinates, HTVComplex(re: 0, im: 0))
        XCTAssertEqual(b.poincare.coordinates, HTVComplex(re: 0.3, im: 0))
        XCTAssertEqual(a.screen.coordinates, HTVComplex(re: 0.19607843137254904, im: 0.19607843137254904))
        XCTAssertEqual(b.screen.coordinates, HTVComplex(re: 0.456820512820513, im: 0.21056410256410266))
        XCTAssertEqual(a.screen.point.rounded, CGPoint(x: 120, y: 120))
        XCTAssertEqual(b.screen.point.rounded, CGPoint(x: 146, y: 121))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension CGPoint {

    var rounded: CGPoint { return CGPoint(x: round(x), y: round(y)) }
}
