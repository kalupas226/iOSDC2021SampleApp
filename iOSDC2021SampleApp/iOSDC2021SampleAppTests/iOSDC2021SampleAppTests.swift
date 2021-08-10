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
}
