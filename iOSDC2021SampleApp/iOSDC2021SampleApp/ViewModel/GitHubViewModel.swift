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

    private var cancellables: Set<AnyCancellable> = []

    @Published var searchWord = ""
    @Published var repositories: [GitHubRepository] = []

    init(gitHubAPIClient: GitHubAPIClient) {
        self.gitHubAPIClient = gitHubAPIClient
    }

    func searchButtonTapped() {
        gitHubAPIClient
            .searchRepository(searchWord)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.repositories = $0.items }
            .store(in: &cancellables)
    }
}
