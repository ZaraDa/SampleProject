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

        let exp = expectation(description: "wait for the completion")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [])
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = [uniqueItem, uniqueItem]

        let saveEXP = expectation(description: "wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveEXP.fulfill()
        }
        wait(for: [saveEXP], timeout: 1.0)

        let loadExp = expectation(description: "wait for load completion")
        sutToPerformLoad.load { result in
            switch result {
            case let .success(recievedImages):
                XCTAssertEqual(recievedImages, feed)
            case let .failure(error):
                XCTFail("Expected successfully recieve images, got \(error)")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
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
}
