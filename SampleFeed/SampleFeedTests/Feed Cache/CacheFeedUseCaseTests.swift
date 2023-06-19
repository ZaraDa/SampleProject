//
//  FeedCacheUseCaseTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 19.06.23.
//

import XCTest
import SampleFeed


class LocalFeedLoader {
    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {

        store.deleteCachedFeed()
    }

}

class FeedStore {
    var deleteCachedFeedCount = 0

    func deleteCachedFeed() {
        deleteCachedFeedCount += 1
    }
}


class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {

        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCount, 0)
    }

    func test_save_deletesCache() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem, uniqueItem]

        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCount, 1)

    }

    //MARK: - helpers

    var uniqueItem: FeedItem {
        FeedItem(id: UUID(),
                 description: "any",
                 location: "any",
                 imageURL: anyURL)
    }

}
