//
//  FeedItem.swift
//  SampleFeed
//
//  Created by Zara Davtian on 28.05.23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL

}
