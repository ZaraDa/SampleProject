//
//  SampleFeedEndToEndTests.swift
//  SampleFeedEndToEndTests
//
//  Created by Zara Davtian on 13.06.23.
//

import XCTest
import SampleFeed

class SampleFeedEndToEndTests: XCTestCase {

    /// matches fixed test account data
    func test_endToEndTestServerGETFeedResult() {

        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    //MARK: -- helpers

    func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        let exp = expectation(description: "wait for load completion")
        var recievedResult: FeedLoader.Result?
        loader.load { result in
            recievedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return recievedResult
    }

}
