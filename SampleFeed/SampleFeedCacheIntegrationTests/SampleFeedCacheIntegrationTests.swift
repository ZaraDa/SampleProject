//
//  SampleFeedCacheIntegrationTests.swift
//  SampleFeedCacheIntegrationTests
//
//  Created by Zara Davtian on 04.07.23.
//

import XCTest
import SampleFeed

class SampleFeedCacheIntegrationTests: XCTestCase {

    func test_load_delivers_NoItemsOnEmptyCache() {
        let sut = makeSUT()

        let exp = expectation(description: "wait for the completion")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [])
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private var testSpecificStoreURL: URL {
        cachesDirectory.appendingPathComponent("\(type(of: self)).store")
    }

    var cachesDirectory: URL {
         FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
