//
//  HomeViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 15/01/26.
//

import Combine
import SwiftUI

enum HomeMode {
    case home
    case notifications
    case lessons
    case frazes
}

class HomeViewModel: ObservableObject {
    @Published var mode: HomeMode = .home

    // можно прокинуть зависимости сюда позже (api/service)
    let notificationsVM = NotificationsViewModel()
    let lessonsVM = LessonsViewModel()
    let frazesVM = FrazesViewModel()

    func openNotifications() {
        withAnimation(.easeInOut) {
            mode = .notifications
        }
    }

    func closeNotifications() {
        withAnimation(.easeInOut) {
            mode = .home
        }
    }
    
    func openFrazes() {
        withAnimation(.easeInOut) {
            mode = .frazes
        }
    }
    
    func openLessons() {
        withAnimation(.easeInOut) {
            mode = .lessons
        }
    }
}
