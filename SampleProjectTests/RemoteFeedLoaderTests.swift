//
//  RemoteFeedLoaderTests.swift
//  SampleProjectTests
//
//  Created by Zara Davtian on 26.05.23.
//

import XCTest

class RemoteFeedLoader {

}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {

        let client = HTTPClient()
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

}
