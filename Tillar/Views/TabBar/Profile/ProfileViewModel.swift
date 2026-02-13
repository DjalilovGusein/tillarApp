//
//  ProfileViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 13/02/26.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var user: AuthUser?
    @Published var isLoading = false
    @Published var errorText: String?

    struct StatItem: Identifiable {
        let id = UUID()
        let value: String
        let label: String
        let sfSymbol: String
        let color: String // color name matching assets or system color
    }

    let stats: [StatItem] = [
        .init(value: "24", label: "Урока", sfSymbol: "book.fill", color: "blue"),
        .init(value: "7", label: "Дней", sfSymbol: "flame.fill", color: "orange"),
        .init(value: "4326", label: "Монет", sfSymbol: "star.fill", color: "yellow")
    ]

    func loadUserInfo() {
        isLoading = true
        errorText = nil

        APIManager.shared.userInfo { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let resp):
                    self.user = resp.user
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    func logout() {
        UD.accessToken = ""
        UD.refreshToken = ""
    }

    var displayName: String {
        if let first = user?.firstName, let last = user?.lastName,
           !first.isEmpty || !last.isEmpty {
            return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        }
        return user?.username ?? "Пользователь"
    }

    var initials: String {
        let name = displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String((parts[0].first ?? "?")).uppercased() +
                   String((parts[1].first ?? "?")).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
