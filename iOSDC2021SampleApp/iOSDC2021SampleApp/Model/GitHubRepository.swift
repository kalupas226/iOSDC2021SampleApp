//
//  GitHubRepository.swift
//  iOSDC2021SampleApp
//
//  Created by Kenta Aikawa on 2021/08/03.
//

import Foundation

struct GitHubRepository: Decodable, Identifiable, Equatable {
    let id: Int
    let fullName: String
}

extension GitHubRepository {
    private enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
    }
}

struct GitHubRepositoryList: Decodable {
    let items: [GitHubRepository]
}
