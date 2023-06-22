//
//  LoadFeedFromCacheUseCaseTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 21.06.23.
//

import XCTest
import SampleFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotRecieveMessagesUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.recievedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load{ _ in }

        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }

    func test_load_failsOnRetrieval() {
        let (sut, store) = makeSUT()

        let retrievalError = anyNSError

        expect(sut, completeWithResult: .failure(retrievalError),
               when: {
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, completeWithResult: .success([]),
               when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCachedImagesOnLessThanSevenDaysCache() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().adding(days: -7)!.adding(minuts: +1)!

        expect(sut, completeWithResult: .success(images),
               when: {
            store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)
        })
    }

    func test_load_deliversNoImagesOnSevenDaysCache() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().adding(days: -7)!

        expect(sut, completeWithResult: .success([]),
               when: {
            store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysCache() {
        let (sut, store) = makeSUT()

        let images = [uniqueItem, uniqueItem]
        let timestamp = Date().adding(days: -7)!.adding(minuts: -1)!

        expect(sut, completeWithResult: .success([]),
               when: {
            store.completeRetrievalWithCachedImages(images: images.toLocal(), timestamp: timestamp)
        })
    }

    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        store.completeRetrieval(with: anyNSError)

        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
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

    private func expect(_ sut: LocalFeedLoader,
                        completeWithResult expectedResult: LocalFeedLoader.LoadResult,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {

        let exp = expectation(description: "wait for completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedImages), .success(expectedImages)):
                XCTAssertEqual(recievedImages, expectedImages)
            case let (.failure(recievedError), .failure(expectedError)):
                XCTAssertEqual(recievedError as NSError, expectedError as NSError)
            default:
                XCTFail("expected \(expectedResult), got \(recievedResult)")
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

}

private extension Date {
    func adding(days: Int) -> Date? {
         Calendar.current.date(byAdding: .day, value: days, to: self)
    }

    func adding(minuts: Int) -> Date? {
        Calendar.current.date(byAdding: .minute, value: minuts, to: self)
    }
}
