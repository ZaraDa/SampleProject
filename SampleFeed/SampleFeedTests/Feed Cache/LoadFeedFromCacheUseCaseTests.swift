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

        var recievedError: Error?
        let exp = expectation(description: "wait for completion")
        sut.load { error in
            recievedError = error
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedError as? NSError, retrievalError)
    }

    //MARK: - helpers

    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
