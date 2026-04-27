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

    @Published var user: UserInfoResponse?

    func login(username: String, password: String, completion: @escaping(() -> ())) {
        isLoading = true
        errorText = nil
        
        APIManager.shared.login(.init(username: username, password: password)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let resp):
                    if resp.success == false {
                        self.errorText = resp.message ?? ""
                    } else {
                        if let tokens = resp.tokens {
                            UD.accessToken = tokens.accessToken ?? ""
                            UD.refreshToken = tokens.refreshToken ?? ""
                            debugPrint("💾 Tokens saved. Access: \(UD.accessToken.prefix(30))...")
                            APIManager.shared.getSocketToken { [weak self] token in
                                guard let self else { return }
                                switch token {
                                case .success(let resp):
                                    UD.sokenToken = resp.token ?? ""
                                    completion()
                                case .failure(let err):
                                    debugPrint(err)
                                }
                            }
                            
                        }
                        
                    }
                    
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func register(username: String,
                  password: String,
                  email: String,
                  firstName: String,
                  lastName: String,
                  phoneNumber: String,
                  completion: @escaping((RegisterResponse) -> ())) {
        
        isLoading = true
        errorText = nil
        APIManager.shared.register(RegisterRequest(username: username, email: email, password: password, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let resp):
                    if resp.success ?? true {
                        if let tokens = resp.tokens {
                            UD.accessToken = tokens.accessToken ?? ""
                            UD.refreshToken = tokens.refreshToken ?? ""
                        }
                        completion(resp)
                    } else {
                        self.errorText = resp.error ?? ""
                    }
                    
                    
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func finishRegistration(otp: String, phoneNumber: String, completion: @escaping (() -> ())) {
        isLoading = true
        errorText = nil
        APIManager.shared.otp(OTP(phone_number: phoneNumber, code: otp)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let resp):
                    if resp.success ?? true {
                        completion()
                    } else {
                        self.errorText = resp.message ?? ""
                    }
                    
                    
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    func refresh() {
        isLoading = true
        errorText = nil
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
