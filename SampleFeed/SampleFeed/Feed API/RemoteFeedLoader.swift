//
//  RemoteFeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public final class RemoteFeedLoader {
   private let url: URL
   private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {

    private struct Root: Decodable {
        let items: [Item]
    }


    private struct Item: Decodable {
         let id: UUID
         let description: String?
         let location: String?
         let image: URL

        var item: FeedItem {
             FeedItem(id: id,
                      description: description,
                      location: location,
                      imageURL: image)
        }
    }


    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return try JSONDecoder().decode(Root.self, from: data).items.map({ $0.item })
    }
}


