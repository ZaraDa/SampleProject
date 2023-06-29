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

        expect(sut: sut, toRetrieve: .empty)
  }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
       let sut = makeSUT()

        expect(sut: sut, toRetrieveTwice: .empty)
  }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {
       let sut = makeSUT()
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieve: .found(FeedCache(images: images, timestamp: timestamp)))
  }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieveTwice: .found(FeedCache(images: images, timestamp: timestamp)))
    }

    func test_retrieve_deliversFailureOnRetrivalError() {
        let sut = makeSUT()

        try! "invalid Data".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieve: .failure(anyNSError))
    }

    func test_retrieve_HasNoSideEffectsOnRetrivalError() {
        let sut = makeSUT()

        try! "invalid Data".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieveTwice: .failure(anyNSError))
    }

    func test_insertOverridesPreviousInseredCache() {
        let sut = makeSUT()

        let images1 = [uniqueItem, uniqueItem].toLocal()
        let timestamp1 = Date()

        insert(for: sut, images: images1, timestamp: timestamp1)

        let images2 = [uniqueItem, uniqueItem].toLocal()
        let timestamp2 = Date()

        insert(for: sut, images: images2, timestamp: timestamp2)

        expect(sut: sut, toRetrieve: .found(FeedCache(images: images2, timestamp: timestamp2)))
    }

    func test_insertDeliversErrorOnInsertionError() {
       let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        let error = insert(for: sut, images: images, timestamp: timestamp)
        XCTAssertNotNil(error)
    }

    func test_hasNoSideEffectsInsertionError() {
       let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieve: .empty)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = delete(for: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed")

        expect(sut: sut, toRetrieve: .empty)
    }

    func test_delete_NonEmptyCacheMakesItEmpty() {
        let sut = makeSUT()
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        let insertionError = insert(for: sut, images: images, timestamp: timestamp)
        XCTAssertNil(insertionError)


        let deletionError = delete(for: sut)
        XCTAssertNil(deletionError)

        expect(sut: sut, toRetrieve: .empty)
    }

    func test_storeSideEffectsrunSerially() {
        let sut = makeSUT()

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

    private func expect(sut: FeedStore, toRetrieve expectedResult: FeedRetrievalResult) {

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

    private func expect(sut: FeedStore, toRetrieveTwice result: FeedRetrievalResult) {
        expect(sut: sut, toRetrieve: result)
        expect(sut: sut, toRetrieve: result)
    }

    @discardableResult
    private func insert(for sut: FeedStore, images: [LocalFeedImage], timestamp: Date) -> Error? {
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
    private func delete(for sut: FeedStore) -> Error? {
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
}
