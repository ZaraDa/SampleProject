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

    func assertThatRetrieveDeliversEmptyOnEmptyCache(sut: FeedStore) {
        expect(sut: sut, toRetrieve: .empty)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(sut: FeedStore) {
        expect(sut: sut, toRetrieveTwice: .empty)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore) {
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieve: .found(FeedCache(images: images, timestamp: timestamp)))
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(sut: FeedStore) {
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieveTwice: .found(FeedCache(images: images, timestamp: timestamp)))
    }

    func assertThatRetrieveDeliversFailureOnRetrivalError(sut: FeedStore, testURL: URL) {
        try! "invalid Data".write(to: testURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieve: .failure(anyNSError))
    }

    func assertThatRetrievHasNoSideEffectsOnRetrivalError(sut: FeedStore, testURL: URL) {
        try! "invalid Data".write(to: testURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieveTwice: .failure(anyNSError))
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore) {
        let images1 = [uniqueItem, uniqueItem].toLocal()
        let timestamp1 = Date()

        insert(for: sut, images: images1, timestamp: timestamp1)

        let images2 = [uniqueItem, uniqueItem].toLocal()
        let timestamp2 = Date()

        insert(for: sut, images: images2, timestamp: timestamp2)

        expect(sut: sut, toRetrieve: .found(FeedCache(images: images2, timestamp: timestamp2)))
    }

    func assertInsertDeliversErrorOnInsertionError(sut: FeedStore) {
         let images = [uniqueItem, uniqueItem].toLocal()
         let timestamp = Date()

         let error = insert(for: sut, images: images, timestamp: timestamp)
         XCTAssertNotNil(error)
    }

    func  assertHasNoSideEffectsOnInsertionError(sut: FeedStore) {
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieve: .empty)
    }

    func assertDeleteHasNoSideEffectsOnEmptyCache(sut: FeedStore) {
        let deletionError = delete(for: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed")

        expect(sut: sut, toRetrieve: .empty)
    }

    func assertDeleteNonEmptyCacheLeavesItEmpty(sut: FeedStore) {
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        let insertionError = insert(for: sut, images: images, timestamp: timestamp)
        XCTAssertNil(insertionError)


        let deletionError = delete(for: sut)
        XCTAssertNil(deletionError)

        expect(sut: sut, toRetrieve: .empty)
    }

    func assertStoreSideEffectsRunSerially(sut: FeedStore) {
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        var completedOperationsOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Opration 1")
        sut.insert(images, timestamp: timestamp) { _ in
            completedOperationsOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Opration 3")
        sut.insert(images, timestamp: timestamp) { _ in
            completedOperationsOrder.append(op3)
            op3.fulfill()
        }

        wait(for: [op1, op2, op3], timeout: 1.0)

        XCTAssertEqual(completedOperationsOrder, [op1, op2, op3])
    }

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
            XCTAssertNil(recievedError, "Expected to successfully delete cache")
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
