//
//  LocalFeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {

    private let store: FeedStore
    private var currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
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
            case let .found(cache) where FeedCachePolicy.validate(timestamp: cache.timestamp, against: self.currentDate()):
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
            case let .found(cache) where !FeedCachePolicy.validate(timestamp: cache.timestamp, against: self.currentDate()):
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
