//
//  DateHelper.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 22.06.23.
//

import Foundation


extension Date  {
    func adding(days: Int) -> Date? {
         Calendar.current.date(byAdding: .day, value: days, to: self)
    }

    func adding(minuts: Int) -> Date? {
        Calendar.current.date(byAdding: .minute, value: minuts, to: self)
    }

    func minusFeedCacheMaxAge() -> Date? {
        self.adding(days: -7)
    }
}
