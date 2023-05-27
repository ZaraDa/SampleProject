//
//  RemoteFeedLoaderTests.swift
//  SampleProjectTests
//
//  Created by Zara Davtian on 26.05.23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()

    private init() {}

    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {

        let client = HTTPClient.shared
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
