//
//  CoreDataFeedStore.swift
//  SampleFeed
//
//  Created by Zara Davtian on 29.06.23.
//

import Foundation


import CoreData

final public class CoreDataFeedStore: FeedStore {


    private let container: NSPersistentContainer

    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

   public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
       perform { context in
                   do {
                       try ManagedFeedCache.find(in: context).map(context.delete).map(context.save)
                       completion(nil)
                   } catch {
                       completion(error)
                   }
               }
    }

    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
                    do {
                        let managedCache = try ManagedFeedCache.newUniqueInstance(in: context)
                        managedCache.timestamp = timestamp
                        managedCache.feed = ManagedFeedItem.images(from: items, in: context)
                        try context.save()
                        completion(nil)
                    } catch {
                        completion(error)
                    }
                }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedFeedCache.find(in: context) {
                    completion(.success(.found(FeedCache(images: cache.localFeed, timestamp: cache.timestamp))))
                } else {
                    completion(.success(.empty))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
            let context = self.context
            context.perform { action(context) }
        }

}


