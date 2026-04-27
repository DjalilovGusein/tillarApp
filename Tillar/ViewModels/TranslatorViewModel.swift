//
//  TranslatorViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 27/02/26.
//

//
//  TranslatorViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 27/02/26.
//

import Foundation
import Combine
import AVFoundation

@MainActor
final class TranslatorViewModel: NSObject, ObservableObject {

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
    private var ttsResult: TTSResponse?

    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()

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

    func playSound() {
        guard let translatedText = translate?.data?.translatedText,
              !translatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorText = "Нет текста для озвучивания"
            return
        }

        isLoading = true
        errorText = nil

        APIManager.shared.textToSpeech(
            ttsRequest(message: translatedText)
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .success(let tts):
                    self.ttsResult = tts
                    self.playReceivedAudio(from: tts)

                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    private func playReceivedAudio(from response: TTSResponse) {
        guard let base64String = response.data?.audioBase64,
              !base64String.isEmpty else {
            errorText = "Пустой audioBase64"
            return
        }

        let cleanedBase64 = base64String
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard let audioData = Data(base64Encoded: cleanedBase64) else {
            errorText = "Не удалось декодировать base64"
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            errorText = "Ошибка воспроизведения: \(error.localizedDescription)"
        }
    }

    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
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
