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
        case .home: return "Главный"
        case .translator: return "Переводчик"
        case .chat: return "Чат"
        case .profile: return "Профиль"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "homeBar"
        case .translator: return "translateBar"
        case .chat: return "chatBar"
        case .profile: return "profileBar"
        }
    }
}
