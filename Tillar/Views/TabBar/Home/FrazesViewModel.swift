//
//  FrazesViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 10/03/26.
//

import Foundation

class FrazesViewModel: ObservableObject {
    @Published var frazes: [Fraze] = []
    @Published var isLoading = false
    @Published var errorText: String?
    
    init() {
        getFrazes()
    }
    
    func getFrazes() {
        isLoading = true
        errorText = nil
        APIManager.shared.getFrazes { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let frazes):
                    self.frazes = frazes.data ?? []
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
}
