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
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }

    private func cache(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
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

    func test_save_failsOnDeletionError(file: StaticString = #file,
                                        line: UInt = #line) {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError

        expect(sut: sut, toCompleteWithError: deletionError, file: file, line: line, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_failsOnInsertionError(file: StaticString = #file,
                                         line: UInt = #line) {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError

        expect(sut: sut, toCompleteWithError: insertionError, file: file, line: line, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_succeedsOnInsertionSuccess(file: StaticString = #file,
                                              line: UInt = #line) {
        let (sut, store) = makeSUT()

        expect(sut: sut, toCompleteWithError: nil, file: file, line: line, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_DoesNotRecieveCompletionErrorOnDeletionIfSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recievedResults = [Error?]()

        sut?.save([uniqueItem]) { recievedResults.append($0) }

        sut = nil

        store.completeDeletion(with: anyNSError)

        XCTAssertTrue(recievedResults.isEmpty)
    }

    func test_save_DoesNotRecieveCompletionOnInserionIfSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recievedResults = [Error?]()

        sut?.save([uniqueItem]) { recievedResults.append($0) }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError)

        XCTAssertTrue(recievedResults.isEmpty)
    }



    //MARK: - helpers

    class FeedStoreSpy: FeedStore {


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

    var uniqueItem: FeedItem {
        FeedItem(id: UUID(),
                 description: "any",
                 location: "any",
                 imageURL: anyURL)
    }

    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }

    func expect(sut: LocalFeedLoader,
                toCompleteWithError expectedError: Error?,
                file: StaticString = #file,
                line: UInt = #line,
                when action: () -> Void) {
        let items = [uniqueItem, uniqueItem]
        let exp = expectation(description: "wait for completion")
        var recievedError: Error?
        sut.save(items) { error in
            recievedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedError as? NSError, expectedError as? NSError)
    }
    

}
