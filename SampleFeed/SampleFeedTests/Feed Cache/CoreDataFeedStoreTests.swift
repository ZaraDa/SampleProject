//
//  CoreDataFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 29.06.23.
//

import XCTest
import SampleFeed


class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

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

    func test_insertOverridesPreviousInseredCache() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
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

    //  MARK: - helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {

        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }



}
