//
//  FeedCacheUseCaseTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 19.06.23.
//

import XCTest


class LocalFeedLoader {
    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

}

class FeedStore {
    var deleteCachedFeedCount = 0
}


class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {

        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCount, 0)
    }

}
