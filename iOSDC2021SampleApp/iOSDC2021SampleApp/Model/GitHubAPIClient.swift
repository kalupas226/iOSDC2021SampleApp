//
//  GitHubAPIClient.swift
//  iOSDC2021SampleApp
//
//  Created by Kenta Aikawa on 2021/08/03.
//

import Combine
import Foundation

struct GitHubAPIClient {
    var searchRepository: (String) -> AnyPublisher<GitHubRepositoryList, Never>
}

extension GitHubAPIClient {
    static let live = Self(
        searchRepository: { searchWord in
            URLSession.shared.dataTaskPublisher(
                for: URL(string: "https://api.github.com/search/repositories?q=\(searchWord)")!
            )
            .map { $0.data }
            .decode(type: GitHubRepositoryList.self, decoder: JSONDecoder())
            .replaceError(with: .init(items: []))
            .eraseToAnyPublisher()
        }
    )
}
