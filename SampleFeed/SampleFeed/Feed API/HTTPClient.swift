//
//  HTTPClient.swift
//  SampleFeed
//
//  Created by Zara Davtian on 01.06.23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)

}

public protocol HTTPClient {
    func get(from url:URL, completion: @escaping (HTTPClientResult) -> Void)
}
