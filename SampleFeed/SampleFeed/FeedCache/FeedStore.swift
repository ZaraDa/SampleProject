//
//  FeedStore.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation

public struct FeedCache: Codable {
   public  let images: [LocalFeedImage]
   public  let timestamp: Date

    public init(images: [LocalFeedImage], timestamp: Date) {
        self.images = images
        self.timestamp = timestamp
    }
}

public enum FeedRetrievalResult {
    case empty
    case found(FeedCache)
    case failure(Error)
}


public protocol FeedStore {

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (FeedRetrievalResult) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


