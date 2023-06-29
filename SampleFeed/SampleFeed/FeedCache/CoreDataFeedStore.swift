//
//  CoreDataFeedStore.swift
//  SampleFeed
//
//  Created by Zara Davtian on 29.06.23.
//

import Foundation


import CoreData

final public class CoreDataFeedStore: FeedStore {
    public init() {}

   public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    private class ManagedCache: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var feed: NSOrderedSet
    }

    private class ManagedFeedImage: NSManagedObject {
        @NSManaged var id: UUID
        @NSManaged var imageDescription: String?
        @NSManaged var location: String?
        @NSManaged var url: URL
        @NSManaged var cache: ManagedCache
    }

}
