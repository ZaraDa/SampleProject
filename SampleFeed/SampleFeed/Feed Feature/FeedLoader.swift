//
//  FeedLoader.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
