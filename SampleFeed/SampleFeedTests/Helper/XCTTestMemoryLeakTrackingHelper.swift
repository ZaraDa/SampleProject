//
//  XCTTestMemoryLeakTrackingHelper.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 06.06.23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instanse: AnyObject,
                             file: StaticString = #file,
                             line: UInt = #line) {
        addTeardownBlock { [weak instanse] in
            XCTAssertNil(instanse, "Instanse should have been dealocated. Potential memory leak.", file: file, line: line)
        }
    }
}
