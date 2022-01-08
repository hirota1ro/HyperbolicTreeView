//
//  HTVComplexTests.swift
//  HyperbolicTreeViewTests
//

import XCTest

@testable import HyperbolicTreeView

class HTVComplexTests: XCTestCase {

    func testComplexMult() throws {
        let z = HTVComplex(re: 0, im: 1)
        XCTAssertEqual(z * z, HTVComplex(re: -1, im: 0))
    }

    func testComplexPlusScalar() throws {
        let z0 = HTVComplex(re: 0, im: 0)
        let z1 = z0 + 1
        XCTAssertEqual(z1, HTVComplex(re: 1, im: 0))
        XCTAssertEqual(z1.magnitude, 1, accuracy: 1e-6)
    }

    func testComplexTranslate() throws {
        let t = HTVComplex(re: sqrt(2), im: sqrt(2))
        XCTAssertEqual(HTVComplex(re: 0, im: 0).translate(t), HTVComplex(re: sqrt(2), im: sqrt(2)))
    }
}
