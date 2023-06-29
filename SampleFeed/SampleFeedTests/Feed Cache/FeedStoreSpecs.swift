//
//  FeedStoreSpecs.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 29.06.23.
//

import Foundation

protocol FeedStoreSpecs {
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectsOnEmptyCache()
     func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues()
     func test_retrieve_hasNoSideEffectsOnNonEmptyCache()



     func test_insertOverridesPreviousInseredCache()


     func test_delete_hasNoSideEffectsOnEmptyCache()
     func test_delete_NonEmptyCacheMakesItEmpty()

     func test_storeSideEffectsrunSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrivalError()
    func test_retrieve_HasNoSideEffectsOnRetrivalError()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insertDeliversErrorOnInsertionError()
    func test_hasNoSideEffectsInsertionError()
}

typealias FailableFeedStoreSpec = FailableInsertFeedStoreSpecs & FailableRetrieveFeedStoreSpecs
