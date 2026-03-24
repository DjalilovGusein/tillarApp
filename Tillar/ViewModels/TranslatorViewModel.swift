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
    @Published var translate: translateResponse? {
        didSet {
            debugPrint(translate)
        }
    }

    struct TranslateQuery: Equatable {
        let text: String
        let source: String
        let target: String
    }

    private let trigger = PassthroughSubject<TranslateQuery, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var lastRequestID: UUID?

    init() {
        let prepared = trigger
            .map { query -> TranslateQuery in
                TranslateQuery(
                    text: query.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    source: query.source,
                    target: query.target
                )
            }
            .filter { query in
                !query.text.isEmpty
            }
            .removeDuplicates()

        prepared
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.translate(text: query.text, source: query.source, reciepient: query.target)
            }
            .store(in: &cancellables)
    }

    func scheduleTranslate(text: String, source: String, target: String) {
        trigger.send(.init(text: text, source: source, target: target))
    }

    func translate(text: String, source: String, reciepient: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorText = nil

        let reqID = UUID()
        lastRequestID = reqID

        APIManager.shared.translate(
            translateRequest(text: trimmed, targetLanguage: reciepient, sourceLanguage: source)
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                guard self.lastRequestID == reqID else { return }

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
