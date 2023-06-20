//
//  FeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}


public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
