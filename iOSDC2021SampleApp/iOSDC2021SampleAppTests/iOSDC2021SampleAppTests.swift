//
//  iOSDC2021SampleAppTests.swift
//  iOSDC2021SampleAppTests
//
//  Created by Aikawa Kenta on 2021/07/18.
//

import Combine
import CombineSchedulers
import XCTest
@testable import iOSDC2021SampleApp

class iOSDC2021SampleAppTests: XCTestCase {
    func testInputSearchWords() throws {
        var cancellables: Set<AnyCancellable> = []
        var repositories: [GitHubRepository] = []
        
        let expectedRepositories: [GitHubRepository] = (1...3).map { .init(id: $0, fullName: "Repository \($0)") }
        let scheduler = DispatchQueue.test

        let viewModel = GitHubViewModel(
            gitHubAPIClient: .init(
                searchRepository: { _ in
                    Just(
                        GitHubRepositoryList(items: expectedRepositories)
                    )
                    .eraseToAnyPublisher()
                }
            ),
            scheduler: scheduler.eraseToAnyScheduler()
        )

        viewModel.$repositories
            .sink { repositories = $0 }
            .store(in: &cancellables)
        
        XCTAssertEqual(repositories, [])

        viewModel.searchWord = "search word"
        
//        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 0.33)
        scheduler.advance(by: 0.3)
        XCTAssertEqual(repositories, expectedRepositories)
    }

    func testImmediateScheduledAction() {
        let testScheduler = DispatchQueue.myTest

        var isExecuted = false
        testScheduler.schedule {
            isExecuted = true
        }

        XCTAssertEqual(isExecuted, false)
        testScheduler.advance()
        XCTAssertEqual(isExecuted, true)
    }
    
    func testImmediatePublisherScheduledAction() {
        let testScheduler = DispatchQueue.myTest
        var result: [Int] = []
        var cancellables: Set<AnyCancellable> = []
        
        Just(1)
            .receive(on: testScheduler)
            .sink { result.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(result, [])
        testScheduler.advance()
        XCTAssertEqual(result, [1])
    }
    
    func testDelayScheduledAction() {
        let testScheduler = DispatchQueue.myTest
        
        var isExecuted = false
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) {
            isExecuted = true
        }
        
        XCTAssertEqual(isExecuted, false)
        testScheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(isExecuted, false)
        testScheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(isExecuted, true)
    }

    func testLongLongDelayScheduledAction() {
        let testScheduler = DispatchQueue.myTest
        
        var isExecuted = false
        testScheduler.schedule(after: testScheduler.now.advanced(by: 5000)) {
            isExecuted = true
        }
        
        XCTAssertEqual(isExecuted, false)
        testScheduler.advance(by: 4999)
        XCTAssertEqual(isExecuted, false)
        testScheduler.advance(by: 1)
        XCTAssertEqual(isExecuted, true)
    }
}
