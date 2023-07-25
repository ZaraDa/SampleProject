//
//  FeedStore.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation

public struct FeedCache {
   public  let images: [LocalFeedImage]
   public  let timestamp: Date

    public init(images: [LocalFeedImage], timestamp: Date) {
        self.images = images
        self.timestamp = timestamp
    }
}


public struct CachedFeed {
    public let feedCache: FeedCache

    public init(feedCache: FeedCache) {
        self.feedCache = feedCache
    }
}
      

public protocol FeedStore {


    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void


    // The completion handler can be invoked in any thread.
    // Clients are responsible to dispatch to appropriate thread
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    // The completion handler can be invoked in any thread.
    // Clients are responsible to dispatch to appropriate thread
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    // The completion handler can be invoked in any thread.
    // Clients are responsible to dispatch to appropriate thread
    func retrieve(completion: @escaping RetrievalCompletion)
}


