//
//  CoreDataFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 29.06.23.
//

import XCTest
import SampleFeed

class CoreDataFeedStore: FeedStore {
    public init() {}

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }


}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(sut: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {

    }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {

    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {

    }

    func test_insertOverridesPreviousInseredCache() {

    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {

    }

    func test_delete_NonEmptyCacheMakesItEmpty() {

    }

    func test_storeSideEffectsrunSerially() {

    }

    //  MARK: - helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
       let sut = CoreDataFeedStore()

        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }



}
