//
//  DateHelper.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 22.06.23.
//

import Foundation


extension Date  {
    private func adding(days: Int) -> Date? {
         Calendar.current.date(byAdding: .day, value: days, to: self)
    }

    private var feedCacheMaxAgeInDays: Int {
        return 7
    }

    func minusFeedCacheMaxAge() -> Date? {
        self.adding(days: -feedCacheMaxAgeInDays)
    }
}
extension Date {
    func adding(minuts: Int) -> Date? {
        Calendar.current.date(byAdding: .minute, value: minuts, to: self)
    }
}
