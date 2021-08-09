//
//  GitHubViewModel.swift
//  iOSDC2021SampleApp
//
//  Created by Kenta Aikawa on 2021/08/03.
//

import Combine
import CombineSchedulers
import Foundation

final class GitHubViewModel: ObservableObject {
    private let gitHubAPIClient: GitHubAPIClient
    private let scheduler: AnySchedulerOf<DispatchQueue>

    private var cancellables: Set<AnyCancellable> = []

    @Published var searchWord = ""
    @Published var repositories: [GitHubRepository] = []
    @Published var isLoading = false

    init(gitHubAPIClient: GitHubAPIClient, scheduler: AnySchedulerOf<DispatchQueue>) {
        self.gitHubAPIClient = gitHubAPIClient
        self.scheduler = scheduler

        $searchWord
            .debounce(for: .milliseconds(300), scheduler: scheduler)
            .sink { [weak self] in
                guard let self = self else { return }

                self.isLoading = true

                gitHubAPIClient
                    .searchRepository($0)
                    .receive(on: scheduler)
                    .sink {
                        self.repositories = $0.items
                        self.isLoading = false
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
}
