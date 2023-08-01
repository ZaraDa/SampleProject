//
//  UIRefreshControl+TestHelpers.swift
//  SampleFeediOSTests
//
//  Created by Zara Davtian on 01.08.23.
//

import Foundation
import UIKit


extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
