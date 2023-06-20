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

    func save(_ items: [FeedItem]) {

        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: currentDate())
            }
        }
    }

}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    enum RecievedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }

    var recievedMessages = [RecievedMessage]()

    private var deletionCompletions = [DeletionCompletion]()

    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        recievedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        recievedMessages.append(.insert(items, timestamp))
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

        sut.save(items)

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let deletionError = anyNSError

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let items = [uniqueItem, uniqueItem]

        sut.save(items)
        store.completeDeletionSuccessfully()


        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
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
