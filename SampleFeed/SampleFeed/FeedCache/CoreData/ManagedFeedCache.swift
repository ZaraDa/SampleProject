//
//  ManagedFeedCache.swift
//  SampleFeed
//
//  Created by Zara Davtian on 04.07.23.
//

import CoreData

@objc(ManagedFeedCache)
class ManagedFeedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet

    var localFeed: [LocalFeedImage] {
            return feed.compactMap { ($0 as? ManagedFeedItem)?.local }
        }
}

extension ManagedFeedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedFeedCache? {
            let request = NSFetchRequest<ManagedFeedCache>(entityName: entity().name!)
            request.returnsObjectsAsFaults = false
            return try context.fetch(request).first
        }
}

extension ManagedFeedCache {
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedFeedCache {
            try find(in: context).map(context.delete)
            return ManagedFeedCache(context: context)
        }
}
