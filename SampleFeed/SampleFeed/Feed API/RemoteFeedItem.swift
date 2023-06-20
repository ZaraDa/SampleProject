//
//  RemoteFeedItem.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation


internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL

    internal var item: FeedImage {
        FeedImage(id: id,
                  description: description,
                  location: location,
                  url: image)
    }
}
