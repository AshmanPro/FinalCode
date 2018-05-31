//
//  CollaboratorTests.swift
//  CollaboratorTests
//
//  Created by Ashman Malik on 7/5/18.
//  Copyright © 2018 Ashman Malik. All rights reserved.
//

import XCTest
@testable import Collaborator

class CollaboratorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func TestforSuccess() {
        
        // Testing The ColModel
        
        // Test 1
        let collaborationPoint = colitem.init(task: "Collaboration Point 1", collaboration: "", log: [""])
        XCTAssertNotNil(collaborationPoint)
        XCTAssertEqual("Collaboration Point 1", collaborationPoint.task)
        
        // Test 2
        
        let collaborationPoint1 = colitem.init(task: "Collaboration Point 1", collaboration: "something", log: [""])
        XCTAssertNotNil(collaborationPoint1)
        XCTAssertEqual("Collaboration Point 1", collaborationPoint1.task)
        XCTAssertEqual("something", collaborationPoint1.collaboration)
        
        // Test 3
        
        let collaborationPoint2 = colitem.init(task: "Collaboration Point 1", collaboration: "something", log: ["hello", "Whatever"])
        XCTAssertNotNil(collaborationPoint2)
        XCTAssertEqual("Collaboration Point 1", collaborationPoint2.task)
        XCTAssertEqual("something", collaborationPoint2.collaboration)
        XCTAssertEqual(["hello", "Whatever"], collaborationPoint2.log)
        
        // Testing the List
       
        var TheListofTask = colList().itemList
        
        let item = colitem(task: collaborationPoint.task, collaboration: "", log: [""])
        TheListofTask.append(item)
        XCTAssertNotNil(TheListofTask)
        // Check the Count in the List
        XCTAssertEqual(1, TheListofTask.count)
        
        
        // The ColList and ColModel Have passed Test Successfully.
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
