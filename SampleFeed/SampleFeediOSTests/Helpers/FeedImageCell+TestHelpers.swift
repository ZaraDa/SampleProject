//
//  FeedImageCell+TestHelpers.swift
//  SampleFeediOSTests
//
//  Created by Zara Davtian on 01.08.23.
//

import UIKit
import SampleFeediOS

extension FeedImageCell {

    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }

    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }

    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }

    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }

}
