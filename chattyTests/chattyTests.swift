//
//  chattyTests.swift
//  chattyTests
//
//  Created by Ing. Ebu Celik on 08.07.22.
//

import XCTest
@testable import chatty

class chattyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculation() throws {
        let a = 10
        let b = 17

        let result = a + b

        XCTAssertTrue(result == 27)
    }

    func testCalculationFailure() throws {
        let a = 10
        let b = 8

        let result = a + b

        XCTAssertTrue(result != 1)
    }

}
