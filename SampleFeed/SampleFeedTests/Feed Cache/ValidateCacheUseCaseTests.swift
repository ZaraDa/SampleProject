//
//  ValidateCacheUseCaseTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 22.06.23.
//

import XCTest
import SampleFeed

class ValidateCacheUseCaseTests: XCTestCase {

    func test_init_doesNotRecieveMessagesUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_validateCache_DeletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrieval(with: anyNSError)

        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_DoesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteCacheNonExpiredCache() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().minusFeedCacheMaxAge()!.adding(minuts: +1)!

        sut.validateCache()

        store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)

        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }

    func test_validateCache_DeletesCacheExpiration() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().minusFeedCacheMaxAge()!

        sut.validateCache()

        store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)

        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_DeletesExpiredCache() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().minusFeedCacheMaxAge()!.adding(minuts: -1)!

        sut.validateCache()

        store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)

        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()

        sut = nil

        store.completeRetrieval(with: anyNSError)

        XCTAssertTrue(store.recievedMessages == [.retrieve])
    }

    
    //MARK: - helpers

   private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
