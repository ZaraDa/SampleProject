//
//  FeedRefreshController.swift
//  SampleFeediOS
//
//  Created by Zara Davtian on 01.08.23.
//

import UIKit
import SampleFeed

final class FeedRefreshViewController: NSObject, FeedLoadingView {

    private(set) lazy var view = loadView()

    private let loadFeed: () -> Void

    init(loadFeed: @escaping () -> Void) {
            self.loadFeed = loadFeed
    }


    @objc func refresh() {
        loadFeed()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
