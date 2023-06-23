//
//  CodableFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 23.06.23.
//

import XCTest
import SampleFeed

class CodableFeedStore {

    private let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("feed_store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let decoder = JSONDecoder()
        guard let cache = try? decoder.decode(FeedCache.self, from: Data(contentsOf: storeURL)) else {
            completion(.empty)
            return
        }

        completion(.found(cache))

    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let feedCache = FeedCache(images: items, timestamp: timestamp)

        let encoder = JSONEncoder()
        let encodedData = try! encoder.encode(feedCache)
        try! encodedData.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {


    override func setUp() {
        super.setUp()

        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("feed_store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()

        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("feed_store")
        try? FileManager.default.removeItem(at: storeURL)
    }


    func test_retrieve_deliversEmptyOnEmptyCache() {
       let sut = CodableFeedStore()

        let exp = expectation(description: "wait for completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result")
            }
            exp.fulfill()
    }
        wait(for: [exp], timeout: 1.0)
  }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
       let sut = CodableFeedStore()

        let exp = expectation(description: "wait for completion")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty results from retrieving from cache twice, but got \(firstResult) and \(secondResult)")
                }
            }
            exp.fulfill()
    }
        wait(for: [exp], timeout: 1.0)
  }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {
       let sut = CodableFeedStore()
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        let retrieveExp = expectation(description: "wait for completion")

        sut.insert(images, timestamp: timestamp) { insertionError in
                XCTAssertNil(insertionError)
                sut.retrieve { result in
                    switch result {
                    case let .found(cache):
                        XCTAssertEqual(images, cache.images)
                        XCTAssertEqual(timestamp, cache.timestamp)
                    default:
                        XCTFail("expected to retrieve items got \(result)")
                    }
                    retrieveExp.fulfill()
                }
        }

        wait(for: [retrieveExp], timeout: 1.0)
  }
}
