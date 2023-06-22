//
//  LocalFeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {

    let calendar = Calendar(identifier: .gregorian)

    private let store: FeedStore
    private var currentDate: () -> Date

    var maxCacheDaysInDays: Int {
        return 7
    }

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }


    private func validate(timestamp: Date) -> Bool {
        guard let maxValidCache = calendar.date(byAdding: .day, value: maxCacheDaysInDays, to: timestamp) else {
            return false
        }

        return currentDate() < maxValidCache
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }

    private func cache(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items.toLocal(), timestamp: self.currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve {[weak self] result in
            guard let self = self else { return }

            switch result {
            case let .found(cache) where self.validate(timestamp: cache.timestamp):
                completion(.success(cache.images.toModel()))
            case .found, .empty:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve {[weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self.store.deleteCachedFeed {_ in }
            case let .found(cache) where !self.validate(timestamp: cache.timestamp):
                self.store.deleteCachedFeed {_ in }
            default:
                break
            }
        }
    }
}



public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        self.map{ LocalFeedImage(id: $0.id,
                                description: $0.description,
                                location: $0.location,
                                url: $0.url
        )}
    }
}

public extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        self.map{ FeedImage(id: $0.id,
                                description: $0.description,
                                location: $0.location,
                                url: $0.url
        )}
    }
}
