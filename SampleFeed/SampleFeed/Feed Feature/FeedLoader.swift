//
//  FeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
