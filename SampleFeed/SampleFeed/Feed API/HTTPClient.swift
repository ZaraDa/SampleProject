//
//  HTTPClient.swift
//  SampleFeed
//
//  Created by Zara Davtian on 01.06.23.
//

import Foundation



public protocol HTTPClient {

    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    // The completion handler can be invoked in any thread.
    // Clients are responsible to dispatch to appropriate thread
    func get(from url:URL, completion: @escaping (Result) -> Void)
}
