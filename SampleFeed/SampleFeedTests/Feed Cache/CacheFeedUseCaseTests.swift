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

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {

        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }

}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    var deleteCachedFeedCount = 0
    var insertCallCount = 0

    private var deletionCompletions = [DeletionCompletion]()

    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        deleteCachedFeedCount += 1
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem]) {
        insertCallCount += 1
    }
}


class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCachedFeedCount, 0)
    }

    func test_save_deletesCache() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]

        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCount, 1)
    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let deletionError = anyNSError

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    func test_save_requestInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }

    //MARK: - helpers

    var uniqueItem: FeedItem {
        FeedItem(id: UUID(),
                 description: "any",
                 location: "any",
                 imageURL: anyURL)
    }

    func makeSUT(file: StaticString = #file,
                 line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    

}
