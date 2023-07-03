//
//  CodableFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 23.06.23.
//

import XCTest
import SampleFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpec {


    override func setUp() {
        super.setUp()

        setUpEmptyStoreURL()
    }

    override func tearDown() {
        super.tearDown()

        removeSideEffects()
    }


    func test_retrieve_deliversEmptyOnEmptyCache() {
       let sut = makeSUT()

      assertThatRetrieveDeliversEmptyOnEmptyCache(sut: sut)
  }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
       let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(sut: sut)

  }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {
       let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(sut: sut)
    }

    func test_retrieve_deliversFailureOnRetrivalError() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFailureOnRetrivalError(sut: sut, testURL: testSpecificStoreURL)
    }

    func test_retrieve_HasNoSideEffectsOnRetrivalError() {
        let sut = makeSUT()

        assertThatRetrievHasNoSideEffectsOnRetrivalError(sut: sut, testURL: testSpecificStoreURL)
    }

    func test_insertOverridesPreviousInseredCache() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_insertDeliversErrorOnInsertionError() {
         let invalidStoreURL = URL(string: "invalid://store-url")!
         let sut = makeSUT(storeURL: invalidStoreURL)

        assertInsertDeliversErrorOnInsertionError(sut: sut)
    }

    func test_hasNoSideEffectsInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertHasNoSideEffectsOnInsertionError(sut: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertDeleteHasNoSideEffectsOnEmptyCache(sut: sut)
    }

    func test_delete_NonEmptyCacheMakesItEmpty() {
        let sut = makeSUT()

        assertDeleteNonEmptyCacheLeavesItEmpty(sut: sut)
    }

    func test_storeSideEffectsrunSerially() {
        let sut = makeSUT()

        assertStoreSideEffectsRunSerially(sut: sut)
    }

    //MARK:  -- Helpers

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private var testSpecificStoreURL: URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func setUpEmptyStoreURL() {
        deleteStoreArtifacts()

    }

    private func removeSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
