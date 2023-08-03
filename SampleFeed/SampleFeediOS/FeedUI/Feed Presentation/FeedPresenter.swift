//
//  FeedPresenter.swift
//  SampleFeediOS
//
//  Created by Zara Davtian on 03.08.23.
//


import SampleFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView: class {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedModel)
}

struct FeedModel {
    let feed: [FeedImage]
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader

    var loadingView: FeedLoadingView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?

    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
