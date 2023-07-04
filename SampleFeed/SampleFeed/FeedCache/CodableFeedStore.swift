//
//  CodableFeedStore.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.06.23.
//

import Foundation


public class CodableFeedStore: FeedStore {

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

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    private let storeURL: URL

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }

            do{
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(CodableFeedCache.self, from: data)
                completion(.success(.some(CachedFeed(feedCache: cache.toFeedCache()))))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {

            do {
                let codableImages = items.map{ CodableFeedImage.toCodable(image: $0) }
                let feedCache = CodableFeedCache(images: codableImages, timestamp: timestamp)

                let encoder = JSONEncoder()
                let encodedData = try! encoder.encode(feedCache)

                try encodedData.write(to: storeURL)

                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
