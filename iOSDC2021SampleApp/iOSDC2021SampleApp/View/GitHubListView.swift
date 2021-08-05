//
//  GitHubListView.swift
//  iOSDC2021SampleApp
//
//  Created by Aikawa Kenta on 2021/07/18.
//

import Combine
import SwiftUI

struct GitHubListView: View {
    @ObservedObject private var viewModel: GitHubViewModel

    init(viewModel: GitHubViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search repository", text: $viewModel.searchWord)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search") {
                    viewModel.searchButtonTapped()
                }
            }
            
            List {
                ForEach(viewModel.repositories) { repository in
                    Text(repository.fullName)
                }
            }
        }
        .padding()
    }
}

struct GitHubListView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubListView(
            viewModel: GitHubViewModel(
                gitHubAPIClient: .init(
                    searchRepository: { _ in
                        Just(
                            GitHubRepositoryList(
                                items: (1...40).map { .init(id: $0, fullName: "Repository \($0)") }
                            )
                        )
                        .eraseToAnyPublisher()
                    }
                )
            )
        )
    }
}
