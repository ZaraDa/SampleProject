//
//  FeedItemsMapper.swift
//  SampleFeed
//
//  Created by Zara Davtian on 01.06.23.
//

import Foundation

 final class FeedItemsMapper {

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

     static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
