//
//  XCTestCase+FeedStore.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 29.06.23.
//

import Foundation
import XCTest
import SampleFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
     func insert(for sut: FeedStore, images: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "wait for completion")

        var insertionError: Error?
        sut.insert(images, timestamp: timestamp) { recievedError in
            insertionError = recievedError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
     func delete(for sut: FeedStore) -> Error? {
        var deletionError: Error?

        let exp = expectation(description: "wait for completion")
        sut.deleteCachedFeed { recievedError in
            deletionError = recievedError
            XCTAssertNil(recievedError, "Expected to successfully delete empty cache")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

     func expect(sut: FeedStore, toRetrieve expectedResult: FeedRetrievalResult) {

        let exp = expectation(description: "waiting for retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
            case let (.found(expectedCache), .found(retrievedCache)):
                XCTAssertEqual(expectedCache.images, retrievedCache.images)
                XCTAssertEqual(expectedCache.timestamp, retrievedCache.timestamp)
            default:
                XCTFail("expected \(expectedResult), got \(retrievedResult)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

     func expect(sut: FeedStore, toRetrieveTwice result: FeedRetrievalResult) {
        expect(sut: sut, toRetrieve: result)
        expect(sut: sut, toRetrieve: result)
    }
}
