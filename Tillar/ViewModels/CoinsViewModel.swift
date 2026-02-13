//
//  CoinsViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//


import Foundation

@MainActor
final class CoinsViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorText: String?
    @Published var coins: Int = 0

    func loadBalance() {
        isLoading = true
        errorText = nil

        APIManager.shared.getCoinsBalance { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let resp):
                    self.coins = resp.data?.first?.amount ?? 0
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
}
