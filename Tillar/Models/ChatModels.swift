//
//  ChatModels.swift
//  Tillar
//
//  Created by Gusein Djalilov on 26/03/26.
//

import SwiftUI

struct ChatUserResponse: Codable {
    let success: Bool?
    let status: Int?
    let data: [ChatUser]?
}

struct ChatUser: Codable, Identifiable, Equatable {
    let id: String
    let username: String
    let displayName: String
    var status: String
    var isOnline: Bool {
        return status == "ONLINE"
    }
}

struct ChatRoomsResponse: Codable {
    let success: Bool?
    let status: Int?
    let data: [ChatRoom]?
}

struct ChatRoomsSignleResponse: Codable {
    let success: Bool?
    let status: Int?
    let data: ChatRoom?
}

struct ChatRoom: Codable, Identifiable {
    let id: Int
    let name: String?
    let type: String
    var participants: [ChatUser]
    let createdAt: String
    var lastMessageAt: String
    let unreadCount: Int
}

struct ChatMessagesRequest: Codable {
    let page: Int
    let size: Int
    let roomId: Int
}

struct ChatMessagesResponse: Codable {
    let success: Bool?
    let status: Int?
    let data: [ChatMessage]?
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: Int
    let content: String
    let sender: ChatUser
    let chatRoomId: Int
    let type: String
    let createdAt: String
    let isRead: Bool
    
    var isFromCurrentUser: Bool {
        sender.username == (UD.authUser?.username ?? "")
    }
}

struct CreateChatRoomRequest: Codable {
    let participantIds: [String]
    let type: String
    let name: String?
}

struct SocketChatMessage: Codable {
    let id: String?
    let sender: String
    let content: String?
    let recipient: String?
    let type: String
    let timestamp: String?
}

// MARK: - ChatRoom display helpers

extension ChatRoom {
    private var isDirectRoom: Bool {
        let lowercased = type.lowercased()
        return lowercased == "direct" || lowercased == "private"
    }

    func displayTitle(for userId: String) -> String {
        if isDirectRoom {
            return participants.first(where: { $0.id != userId })?.displayName ?? name ?? "Chat"
        }
        return name ?? "Group"
    }

    func initials(for userId: String) -> String {
        let title = displayTitle(for: userId)
        let parts = title.components(separatedBy: " ").filter { !$0.isEmpty }

        if parts.count >= 2 {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }

        return String(title.prefix(2)).uppercased()
    }

    func isOnline(for userId: String) -> Bool {
        participants.first(where: { $0.id != userId })?.status.lowercased() == "online"
    }

    func avatarColor(for userId: String) -> Color {
        let palette: [Color] = [.blue, .purple, .orange, .green, .pink, .teal]
        let key = participants.first(where: { $0.id != userId })?.id ?? "\(id)"
        return palette[abs(key.hashValue) % palette.count]
    }

    var formattedLastMessageAt: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var parsedDate = iso.date(from: lastMessageAt)

        if parsedDate == nil {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            parsedDate = fallback.date(from: lastMessageAt)
        }

        guard let date = parsedDate else { return "" }

        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }

    func onlineSubtitle(for userId: String) -> String {
        if isDirectRoom {
            return isOnline(for: userId) ? "В сети" : "Не в сети"
        }

        let onlineCount = participants.filter { $0.status.lowercased() == "online" }.count
        return "\(participants.count) участников, \(onlineCount) в сети"
    }
}

// MARK: - ChatMessage display helpers

extension ChatMessage {
    func isFromMe(userId: String) -> Bool {
        sender.id == userId
    }

    var formattedTime: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var parsedDate = iso.date(from: createdAt)

        if parsedDate == nil {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            parsedDate = fallback.date(from: createdAt)
        }

        guard let date = parsedDate else { return "" }

        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }
}
