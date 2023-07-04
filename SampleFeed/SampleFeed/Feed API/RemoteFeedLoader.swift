//
//  RemoteFeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
   private let url: URL
   private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = FeedLoader.Result


    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }


    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) {[weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(Self.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

   private static func map(data: Data,
             response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
              return .success(items.toFeedItem())
        } catch {
             return.failure(error)
        }
    }
}

 extension Array where Element == RemoteFeedItem {
    func toFeedItem() -> [FeedImage] {
        self.map{ FeedImage(id: $0.id,
                                description: $0.description,
                                location: $0.location,
                                url: $0.image
        )}
    }
}

