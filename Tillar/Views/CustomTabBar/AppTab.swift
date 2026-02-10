//
//  AppTab.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//
import Foundation

enum AppTab: Int, CaseIterable {
    case home, translator, chat, profile

    var title: String {
        switch self {
        case .home: return "Главны"
        case .translator: return "Переводчик"
        case .chat: return "Чат"
        case .profile: return "Профиль"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "main"
        case .translator: return "translate"
        case .chat: return "chat"
        case .profile: return "profile"
        }
    }
}
