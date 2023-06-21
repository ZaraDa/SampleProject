//
//  AnyInstancesCreationHelper.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 19.06.23.
//

import Foundation
import XCTest
import SampleFeed


extension XCTestCase {

     var anyURL: URL {
        URL(string: "http://any-url.com")!
    }

     var anyData: Data {
        Data("any data".utf8)
    }

     var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }

     var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }

     var nonHTTPURLResponse: URLResponse {
        URLResponse(url: anyURL,
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }

    var uniqueItem: FeedImage {
        FeedImage(id: UUID(),
                 description: "any",
                 location: "any",
                 url: anyURL)
    }
}
