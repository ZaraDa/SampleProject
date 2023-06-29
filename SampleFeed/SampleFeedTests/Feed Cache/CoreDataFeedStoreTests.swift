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

        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }



}
