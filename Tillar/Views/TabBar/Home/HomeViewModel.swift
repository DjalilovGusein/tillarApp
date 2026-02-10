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
}

class HomeViewModel: ObservableObject {
    @Published var mode: HomeMode = .home

    // можно прокинуть зависимости сюда позже (api/service)
    let notificationsVM = NotificationsViewModel()

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
}
