//
//  UIButton+TestHelpers.swift
//  SampleFeediOSTests
//
//  Created by Zara Davtian on 01.08.23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
