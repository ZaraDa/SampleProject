//
//  FeedViewControllerTests.swift
//  SampleFeed
//
//  Created by Zara Davtian on 27.07.23.
//

import XCTest
import UIKit
import SampleFeed

final class FeedViewController: UIViewController {
    var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load{ _ in }
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _  = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    class LoaderSpy: FeedLoader {
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
                loadCallCount += 1
        }


        private(set) var loadCallCount: Int = 0


    }



}
