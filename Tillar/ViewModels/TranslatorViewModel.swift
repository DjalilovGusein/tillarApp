//
//  TranslatorViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 27/02/26.
//

import Foundation
import Combine

@MainActor
final class TranslatorViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorText: String?
    
    @Published var translate: translateResponse?
    
    
    func translate(text: String, source: String, reciepient: String) {
        APIManager.shared.translate(translateRequest(text: text, targetLanguage: reciepient, sourceLanguage: source)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let translate):
                    self.translate = translate
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
}

enum TranslateLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case russian = "Russian"
    case uzbek = "Uzbek"

    var id: String { rawValue }
}
