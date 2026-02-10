//
//  LoaderService.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import Foundation
import Combine

final class LoaderService: ObservableObject {
    static let shared = LoaderService(); private init() {}

    @Published private(set) var isLoading = false
    private var counter = 0

    func show() {
        DispatchQueue.main.async {
            self.counter += 1
            self.isLoading = true
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.counter = max(self.counter - 1, 0)
            if self.counter == 0 {
                self.isLoading = false
            }
        }
    }

    func reset() {
        DispatchQueue.main.async {
            self.counter = 0
            self.isLoading = false
        }
    }
}
