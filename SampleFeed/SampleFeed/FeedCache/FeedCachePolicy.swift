//
//  FeedCachePolicy.swift
//  SampleFeed
//
//  Created by Zara Davtian on 22.06.23.
//

import Foundation

 final class FeedCachePolicy {

    private init() {}

    private static let calendar = Calendar(identifier: .gregorian)

    static var maxCacheDaysInDays: Int {
        return 7
    }

     static func validate(timestamp: Date, against date: Date) -> Bool {
        guard let maxValidCache = calendar.date(byAdding: .day, value: maxCacheDaysInDays, to: timestamp) else {
            return false
        }

        return date < maxValidCache
    }
}
