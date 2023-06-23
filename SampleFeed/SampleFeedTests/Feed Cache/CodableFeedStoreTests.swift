//
//  CodableFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 23.06.23.
//

import XCTest
import SampleFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {


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
}
