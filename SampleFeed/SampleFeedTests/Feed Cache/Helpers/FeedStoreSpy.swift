//
//  FeedStoreSpy.swift
//  SampleFeedTests
//
//  Created by Zara Davtian on 21.06.23.
//

import Foundation
import SampleFeed

class FeedStoreSpy: FeedStore {


    enum RecievedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    var recievedMessages = [RecievedMessage]()

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        recievedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        recievedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        recievedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
    }

}
