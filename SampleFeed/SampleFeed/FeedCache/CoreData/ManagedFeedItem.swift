//
//  ManagedFeedItem.swift
//  SampleFeed
//
//  Created by Zara Davtian on 04.07.23.
//

import CoreData

@objc(ManagedFeedItem)
class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedFeedCache

        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
        }
}

extension ManagedFeedItem {
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
            return NSOrderedSet(array: localFeed.map { local in
                let managed = ManagedFeedItem(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.url
                return managed
            })
        }
}
