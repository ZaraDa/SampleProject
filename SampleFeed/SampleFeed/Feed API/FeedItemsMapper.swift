//
//  FeedItemsMapper.swift
//  SampleFeed
//
//  Created by Zara Davtian on 01.06.23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL

    internal var item: FeedItem {
         FeedItem(id: id,
                  description: description,
                  location: location,
                  imageURL: image)
    }
}

internal final class FeedItemsMapper {

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
