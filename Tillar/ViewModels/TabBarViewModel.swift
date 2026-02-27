//
//  TabBarViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 27/01/26.
//

import Foundation
import Combine

@MainActor
final class TabBarViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorText: String?

    @Published var user: UserInfoResponse?
    @Published var coins: CoinsBalanceResponse?
    @Published var news: NewsListResponse?
    @Published var courses: CoursesResponse?
    @Published var categories: СategoriesResponse?
    
    init(isLoading: Bool = false, errorText: String? = nil, user: UserInfoResponse? = nil) {
        self.isLoading = isLoading
        self.errorText = errorText
        self.user = user
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
        
        APIManager.shared.getCoinsBalance { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let coins):
                    self.coins = coins
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func getNewsList() {
        APIManager.shared.getNewsList { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let news):
                    self.news = news
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func getNotificationsList() {
        APIManager.shared.getNotifications(completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let notifications):
                    debugPrint(notifications)
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        })
    }
    
    func getUserProgress() {
        APIManager.shared.getUserProgress { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let courses):
                    self.courses = courses
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func getCategories() {
        APIManager.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let categories):
                    self.categories = categories
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func getSubscriptionInfo() {
        APIManager.shared.getSubscriptionInfo { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let categories):
                    debugPrint("Info")
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
}
