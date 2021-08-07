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
    @Published var isLoading = false

    init(gitHubAPIClient: GitHubAPIClient) {
        self.gitHubAPIClient = gitHubAPIClient

        $searchWord
            .sink { [weak self] in
                guard let self = self else { return }

                self.isLoading = true

                gitHubAPIClient
                    .searchRepository($0)
                    .receive(on: DispatchQueue.main)
                    .sink {
                        self.repositories = $0.items
                        self.isLoading = false
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
}
