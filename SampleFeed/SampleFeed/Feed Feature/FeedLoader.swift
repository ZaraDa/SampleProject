//
//  FeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
