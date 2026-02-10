//
//  ToastService.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import SwiftUI
import Combine

enum ToastKind { case success, error, info }

final class ToastService: ObservableObject {
    static let shared = ToastService(); private init() {}

    @Published var message: String?
    @Published var isVisible = false
    @Published var kind: ToastKind = .info

    private var queue: [() -> Void] = []
    private var showing = false

    func show(_ message: String, kind: ToastKind = .error, duration: TimeInterval = 2.2) {
        DispatchQueue.main.async { [weak self] in
            self?.queue.append { [weak self] in
                guard let self else { return }
                self.message = message
                self.kind = kind
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { self.isVisible = true }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.easeInOut(duration: 0.2)) { self.isVisible = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.showing = false; self.drain() }
                }
            }
            self?.drain()
        }
    }

    func show(error: String) {
        show(error, kind: .error)
    }

    private func drain() {
        guard !showing, let job = queue.first else { return }
        showing = true
        queue.removeFirst()
        job()
    }
}
