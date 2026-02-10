//
//  AuthViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorText: String?

    @Published var user: AuthUser?

    func login(username: String, password: String) {
        isLoading = true
        errorText = nil

        APIManager.shared.login(.init(username: username, password: password)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let resp):
                    if let tokens = resp.tokens {
                        UD.accessToken = tokens.accessToken
                        UD.refreshToken = tokens.refreshToken
                    }
                    self.user = resp.user

                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    func refresh() {
        isLoading = true
        errorText = nil

        APIManager.shared.refreshToken { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let env):
                    if let tokens = env.data {
                        UD.accessToken = tokens.accessToken
                        UD.refreshToken = tokens.refreshToken
                    }
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    func loadUserInfo() {
        isLoading = true
        errorText = nil

        APIManager.shared.userInfo { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
}
