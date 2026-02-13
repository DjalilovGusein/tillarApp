//
//  NewsViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//


import Foundation

@MainActor
final class NewsViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorText: String?
    @Published var items: [NewsItem] = []

    func load(page: Int = 0, size: Int = 20) {
        isLoading = true
        errorText = nil
/*
        APIManager.shared.getNewsList(page: page, size: size) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let resp):
                    self.items = resp.data?.content ?? []
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        } */
    }
}
