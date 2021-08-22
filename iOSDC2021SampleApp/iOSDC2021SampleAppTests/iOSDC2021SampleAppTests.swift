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
    
    func testIntervalScheduledAction() {
        let testScheduler = DispatchQueue.myTest
        
        var executeCount = 0
        var cancellables: Set<AnyCancellable> = []
        
        testScheduler.schedule(after: testScheduler.now, interval: 1) {
            executeCount += 1
        }
        .store(in: &cancellables)
        
        XCTAssertEqual(executeCount, 0)
        testScheduler.advance()
        XCTAssertEqual(executeCount, 1)
        testScheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(executeCount, 1)
        testScheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(executeCount, 2)
        testScheduler.advance(by: 4)
        XCTAssertEqual(executeCount, 6)
    }
    
    func testTwoIntervalsScheduledAction() {
        let testScheduler = DispatchQueue.myTest
        
        var values: [String] = []
        let firstInterval = testScheduler.schedule(after: testScheduler.now.advanced(by: 1), interval: 1) {
            values.append("first")
        }
        let secondInterval = testScheduler.schedule(after: testScheduler.now.advanced(by: 2), interval: 2) {
            values.append("second")
        }
        
        XCTAssertEqual(values, [])
        testScheduler.advance(by: 2)
        XCTAssertEqual(values, ["first", "first", "second"])
    }
    
    func testScheduleNow() {
        let testScheduler = DispatchQueue.myTest
        
        var times: [UInt64] = []
        let interval = testScheduler.schedule(after: testScheduler.now, interval: 1) {
            times.append(testScheduler.now.dispatchTime.uptimeNanoseconds)
        }
        
        XCTAssertEqual(times, [])
        testScheduler.advance(by: 3)
        XCTAssertEqual(times, [1, 1_000_000_001, 2_000_000_001, 3_000_000_001])
    }
}
