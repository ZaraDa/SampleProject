//
//  FeedLoader.swift
//  
//
//  Created by Zara Davtian on 26.05.23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
