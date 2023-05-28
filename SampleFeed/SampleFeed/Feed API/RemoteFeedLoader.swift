//
//  RemoteFeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL)
}

public class RemoteFeedLoader {
   public let client: HTTPClient
   public let url: URL

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() {
        client.get(from: url)
    }
}
