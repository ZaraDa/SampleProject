//
//  SampleFeedCacheIntegrationTests.swift
//  SampleFeedCacheIntegrationTests
//
//  Created by Zara Davtian on 04.07.23.
//

import XCTest
import SampleFeed

class SampleFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreURL()
    }

    override func tearDown() {
        super.tearDown()
        removeSideEffects()
    }

    func test_load_delivers_NoItemsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut: sut, toLoad: [])
    }

    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = [uniqueItem, uniqueItem]

        save(feed: feed, with: sutToPerformSave)

        expect(sut: sutToPerformLoad, toLoad: feed)
    }

    func test_save_overridesItemsSavedOnSeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = [uniqueItem, uniqueItem]
        let lastFeed = [uniqueItem, uniqueItem]


        save(feed: firstFeed, with: sutToPerformFirstSave)

        save(feed: lastFeed, with: sutToPerformLastSave)

        expect(sut: sutToPerformLoad, toLoad: lastFeed)

    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private var testSpecificStoreURL: URL {
        cachesDirectory.appendingPathComponent("\(type(of: self)).store")
    }

    private var cachesDirectory: URL {
         FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func setUpEmptyStoreURL() {
        deleteStoreArtifacts()

    }

    private func removeSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

    private func expect(sut: LocalFeedLoader, toLoad images: [FeedImage]) {
        let exp = expectation(description: "wait for the completion")
        sut.load { result in
            switch result {
            case let .success(recievedImages):
                XCTAssertEqual(recievedImages, images)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func save(feed: [FeedImage], with sut: LocalFeedLoader) {
        let saveEXP = expectation(description: "wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case let .failure(error):
                XCTFail("Expected successful result, got an \(error)")

            }
            saveEXP.fulfill()
        }
        wait(for: [saveEXP], timeout: 1.0)
    }
}
