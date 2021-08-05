//
//  iOSDC2021SampleAppTests.swift
//  iOSDC2021SampleAppTests
//
//  Created by Aikawa Kenta on 2021/07/18.
//

import Combine
import XCTest
@testable import iOSDC2021SampleApp

class iOSDC2021SampleAppTests: XCTestCase {
    func testSearchButtonTapped() throws {
        var cancellables: Set<AnyCancellable> = []
        var repositories: [GitHubRepository] = []
        
        let expectedRepositories: [GitHubRepository] = (1...3).map { .init(id: $0, fullName: "Repository \($0)") }
        
        let viewModel = GitHubViewModel(
            gitHubAPIClient: .init(
                searchRepository: { _ in
                    Just(
                        GitHubRepositoryList(items: expectedRepositories)
                    )
                    .eraseToAnyPublisher()
                }
            )
        )
        
        viewModel.$repositories
            .sink { repositories.append(contentsOf: $0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(repositories, [])

        viewModel.searchWord = "search word"
        viewModel.searchButtonTapped()
        
        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 0.1)
        XCTAssertEqual(repositories, expectedRepositories)
    }
}
