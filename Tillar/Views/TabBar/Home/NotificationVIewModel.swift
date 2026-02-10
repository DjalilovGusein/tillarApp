//
//  NotificationVIewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 15/01/26.
//

import SwiftUI

// MARK: - Model

enum NotificationPayload: Equatable {
    case none
    case progress(title: String, subtitle: String, scoreText: String, imageName: String)
}

struct AppNotification: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let message: String
    let time: String
    var isUnread: Bool
    let avatarImageName: String
    let payload: NotificationPayload
}

final class NotificationsViewModel: ObservableObject {

    @Published var items: [AppNotification] = []
    @Published var expandedIDs: Set<UUID> = []

    init() {
        loadMock()
    }

    func toggle(_ item: AppNotification) {
        if expandedIDs.contains(item.id) {
            expandedIDs.remove(item.id)
        } else {
            expandedIDs.insert(item.id)
            markRead(item)
        }
    }

    func isExpanded(_ item: AppNotification) -> Bool {
        expandedIDs.contains(item.id)
    }

    func markRead(_ item: AppNotification) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isUnread = false
    }

    func loadMock() {
        items = [
            AppNotification(
                title: "Tillar AI",
                message: "Lorem ipsum dolor sit amet consectetur.",
                time: "12:25",
                isUnread: true,
                avatarImageName: "robot",      // добавь ассет
                payload: .progress(
                    title: "Мой прогресс",
                    subtitle: "Общий показатель\nуспеваемости:",
                    scoreText: "7/10",
                    imageName: "progressGirl"  // добавь ассет
                )
            ),
            AppNotification(
                title: "Tillar AI",
                message: "Lorem ipsum dolor sit amet consectetur.",
                time: "12:25",
                isUnread: true,
                avatarImageName: "robot",
                payload: .progress(
                    title: "Мой прогресс",
                    subtitle: "Общий показатель\nуспеваемости:",
                    scoreText: "7/10",
                    imageName: "progressGirl"  // добавь ассет
                )
            ),
            AppNotification(
                title: "Tillar AI",
                message: "Lorem ipsum dolor sit amet consectetur.",
                time: "12:25",
                isUnread: false,
                avatarImageName: "robot",
                payload: .progress(
                    title: "Мой прогресс",
                    subtitle: "Общий показатель\nуспеваемости:",
                    scoreText: "7/10",
                    imageName: "progressGirl"  // добавь ассет
                )
            )
        ]
    }
}
