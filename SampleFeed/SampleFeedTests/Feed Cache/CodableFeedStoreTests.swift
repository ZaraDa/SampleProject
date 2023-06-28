//
//  CodableFeedStoreTests.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 23.06.23.
//

import XCTest
import SampleFeed

class CodableFeedStore {

    private struct CodableFeedCache: Codable {
       private  let images: [CodableFeedImage]
       private  let timestamp: Date

        init(images: [CodableFeedImage], timestamp: Date) {
            self.images = images
            self.timestamp = timestamp
        }

        func toFeedCache() -> FeedCache {
            let localImages = images.map{ $0.toLocal() }
            return FeedCache(images: localImages,
                             timestamp: timestamp)
        }
    }

    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        func toLocal() -> LocalFeedImage {
            LocalFeedImage(id: id,
                           description: description,
                           location: location,
                           url: url)
        }

        static func toCodable(image: LocalFeedImage) -> CodableFeedImage {
            CodableFeedImage(id: image.id,
                             description: image.description,
                             location: image.location,
                             url: image.url)
        }
    }

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    private let storeURL: URL

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(CodableFeedCache.self, from: data)
            completion(.found(cache.toFeedCache()))
        } catch {
            completion(.failure(error))
        }
    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let codableImages = items.map{ CodableFeedImage.toCodable(image: $0) }
        let feedCache = CodableFeedCache(images: codableImages, timestamp: timestamp)

        let encoder = JSONEncoder()
        let encodedData = try! encoder.encode(feedCache)
        try! encodedData.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()

        setUpEmptyStoreURL()
    }

    override func tearDown() {
        super.tearDown()

        removeSideEffects()
    }


    func test_retrieve_deliversEmptyOnEmptyCache() {
       let sut = makeSUT(storeURL: testSpecificStoreURL)

        expect(sut: sut, toRetrieve: .empty)
  }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
       let sut = makeSUT(storeURL: testSpecificStoreURL)

        expect(sut: sut, toRetrieveTwice: .empty)
  }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {
       let sut = makeSUT(storeURL: testSpecificStoreURL)
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieve: .found(FeedCache(images: images, timestamp: timestamp)))
  }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT(storeURL: testSpecificStoreURL)
        let images = [uniqueItem, uniqueItem].toLocal()
        let timestamp = Date()

        insert(for: sut, images: images, timestamp: timestamp)

        expect(sut: sut, toRetrieveTwice: .found(FeedCache(images: images, timestamp: timestamp)))
    }

    func test_retrieve_deliversFailureOnRetrivalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid Data".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)

        expect(sut: sut, toRetrieve: .failure(anyNSError))
    }

    //MARK:  -- Helpers

    private func makeSUT(storeURL: URL, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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

    private func expect(sut: CodableFeedStore, toRetrieve expectedResult: FeedRetrievalResult) {

        let exp = expectation(description: "waiting for retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
            case let (.found(expectedCache), .found(retrievedCache)):
                XCTAssertEqual(expectedCache.images, retrievedCache.images)
                XCTAssertEqual(expectedCache.timestamp, retrievedCache.timestamp)
            default:
                XCTFail("expected \(expectedResult), got \(retrievedResult)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(sut: CodableFeedStore, toRetrieveTwice result: FeedRetrievalResult) {
        expect(sut: sut, toRetrieve: result)
        expect(sut: sut, toRetrieve: result)
    }

    private func insert(for sut: CodableFeedStore, images: [LocalFeedImage], timestamp: Date) {
        let exp = expectation(description: "wait for completion")

        sut.insert(images, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
