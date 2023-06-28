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

public enum FeedRetrievalResult {
    case empty
    case found(FeedCache)
    case failure(Error)
}


public protocol FeedStore {

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (FeedRetrievalResult) -> Void


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


