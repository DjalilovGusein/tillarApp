//
//  AppTab.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//
import Foundation

enum AppTab: Int, CaseIterable {
    case home, courses, progress, profile

    var title: String {
        switch self {
        case .home: return "Главная"
        case .courses: return "Курсы"
        case .progress: return "Прогресс"
        case .profile: return "Профиль"
        }
    }

    /// Имена ассетов (как у тебя)
    var iconName: String {
        switch self {
        case .home: return "main"
        case .courses: return "translate"
        case .progress: return "chat"
        case .profile: return "profile"
        }
    }
}
