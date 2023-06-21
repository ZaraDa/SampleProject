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
        sut.load { result in
            switch result {
            case let .failure(error):
                recievedError = error
            default:
                XCTFail("expected failure, got \(result)")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedError as? NSError, retrievalError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        var recievedImages: [FeedImage]?
        let exp = expectation(description: "wait for completion")
        sut.load { result in
            switch result {
            case let .success(images):
                recievedImages = images
            default:
                XCTFail("expected success, got result \(result)")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recievedImages, [])
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
