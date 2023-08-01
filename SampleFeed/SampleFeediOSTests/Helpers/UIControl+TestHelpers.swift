//
//  UIControl+TestHelpers.swift
//  SampleFeediOSTests
//
//  Created by Zara Davtian on 01.08.23.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
