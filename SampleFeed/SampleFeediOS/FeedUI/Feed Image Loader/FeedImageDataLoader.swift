//
//  FeedImageDataLoader.swift
//  SampleFeediOS
//
//  Created by Zara Davtian on 01.08.23.
//

import Foundation

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}
