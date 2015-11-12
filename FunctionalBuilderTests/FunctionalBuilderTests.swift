//
//  FunctionalBuilderTests.swift
//  FunctionalBuilderTests
//
//  Created by Antoine Palazzolo on 22/10/15.
//
//

import XCTest
import FunctionalBuilder

class FunctionalBuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    struct Other : ComposeType {
        var pure : String throws -> String {
            return {$0+$0}
        }
    }
    
    func testComposeProtocol() {
        let f1 = {(v : String) -> Int? in return Int(v)}
        let compose = f1 <&> Other() <&> Other()
        let _ = try? compose.pure("2")
    }
}
