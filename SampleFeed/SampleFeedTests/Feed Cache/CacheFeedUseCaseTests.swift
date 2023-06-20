//
//  FeedCacheUseCaseTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 19.06.23.
//

import XCTest
import SampleFeed


class LocalFeedLoader {
    private let store: FeedStore
    private var currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {

        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: currentDate()) { error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }

}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    enum RecievedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }

    var recievedMessages = [RecievedMessage]()

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        recievedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        recievedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }

}


class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotRecieveMessagesUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_save_deletesCache() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]

        sut.save(items) { _ in }

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let deletionError = anyNSError

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let items = [uniqueItem, uniqueItem]

        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()


        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let deletionError = anyNSError

        let exp = expectation(description: "wait for completion")
        var recievedError: Error?
        sut.save(items) { error in
            recievedError = error
            exp.fulfill()
        }

        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedError as? NSError, deletionError)
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let insertionError = anyNSError

        let exp = expectation(description: "wait for completion")
        var recievedError: Error?
        sut.save(items) { error in
            recievedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedError as? NSError, insertionError)
    }

    func test_save_succeedsOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]

        let exp = expectation(description: "wait for completion")
        var recievedError: Error?
        sut.save(items) { error in
            recievedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)

        XCTAssertNil(recievedError)
    }



    //MARK: - helpers

    var uniqueItem: FeedItem {
        FeedItem(id: UUID(),
                 description: "any",
                 location: "any",
                 imageURL: anyURL)
    }

    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    

}
