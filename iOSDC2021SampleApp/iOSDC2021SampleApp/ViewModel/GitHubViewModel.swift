//
//  GitHubViewModel.swift
//  iOSDC2021SampleApp
//
//  Created by Kenta Aikawa on 2021/08/03.
//

import Combine
import Foundation

final class GitHubViewModel: ObservableObject {
    private let gitHubAPIClient: GitHubAPIClient

    init(gitHubAPIClient: GitHubAPIClient) {
        self.gitHubAPIClient = gitHubAPIClient
    }

    @Published var searchWord = ""
    @Published var repositories: [GitHubRepository] = []

    private var cancellables: Set<AnyCancellable> = []

    func searchButtonTapped() {
        gitHubAPIClient
            .searchRepository(searchWord)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { self.repositories = $0.items })
            .store(in: &cancellables)
    }
}
