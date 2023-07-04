//
//  RemoteFeedItem.swift
//  SampleFeed
//
//  Created by Zara Davtian on 20.06.23.
//

import Foundation


 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL

     var item: FeedImage {
        FeedImage(id: id,
                  description: description,
                  location: location,
                  url: image)
    }
}
