//
//  ChatViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

// MARK: - Models

struct Conversation: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let avatarColor: Color
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let isOnline: Bool
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let time: String
    let isFromMe: Bool
    let isRead: Bool
}

// MARK: - ViewModel

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var conversations: [Conversation] = []
    @Published var searchText: String = ""
    @Published var selectedConversation: Conversation?
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""

    var filteredConversations: [Conversation] {
        if searchText.isEmpty { return conversations }
        return conversations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        loadMockConversations()
    }

    func selectConversation(_ conversation: Conversation) {
        selectedConversation = conversation
        loadMockMessages(for: conversation)
    }

    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let msg = ChatMessage(
            text: trimmed,
            time: currentTimeString(),
            isFromMe: true,
            isRead: false
        )
        messages.append(msg)
        messageText = ""
    }

    // MARK: - Private

    private func currentTimeString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: Date())
    }

    private func loadMockConversations() {
        conversations = [
            Conversation(
                name: "Bekzod.O",
                initials: "BO",
                avatarColor: .blue,
                lastMessage: "Bugun darsga kelasanmi?",
                time: "10:30",
                unreadCount: 3,
                isOnline: true
            ),
            Conversation(
                name: "Jasur.K",
                initials: "JK",
                avatarColor: .green,
                lastMessage: "Rahmat, tushundim!",
                time: "09:15",
                unreadCount: 0,
                isOnline: false
            ),
            Conversation(
                name: "Nargiza.A",
                initials: "NA",
                avatarColor: .purple,
                lastMessage: "Yangi darsni ko'rdingizmi?",
                time: "Вчера",
                unreadCount: 1,
                isOnline: true
            ),
            Conversation(
                name: "Sardor.M",
                initials: "SM",
                avatarColor: .orange,
                lastMessage: "Kurs juda yaxshi ekan",
                time: "Вчера",
                unreadCount: 0,
                isOnline: false
            ),
            Conversation(
                name: "Dilnoza.R",
                initials: "DR",
                avatarColor: .pink,
                lastMessage: "Ingliz tilida gaplashamizmi?",
                time: "Пн",
                unreadCount: 5,
                isOnline: true
            ),
            Conversation(
                name: "Aziz.T",
                initials: "AT",
                avatarColor: .teal,
                lastMessage: "Ok, see you tomorrow!",
                time: "Пн",
                unreadCount: 0,
                isOnline: false
            ),
            Conversation(
                name: "Madina.S",
                initials: "MS",
                avatarColor: .indigo,
                lastMessage: "Qanday ketayapti darslar?",
                time: "Вс",
                unreadCount: 0,
                isOnline: false
            )
        ]
    }

    private func loadMockMessages(for conversation: Conversation) {
        messages = [
            ChatMessage(
                text: "Salom! Bugun darsga kelasanmi?",
                time: "10:00",
                isFromMe: false,
                isRead: true
            ),
            ChatMessage(
                text: "Salom! Ha, albatta kelaman",
                time: "10:05",
                isFromMe: true,
                isRead: true
            ),
            ChatMessage(
                text: "Yaxshi! Yangi mavzu boshlaymiz bugun",
                time: "10:10",
                isFromMe: false,
                isRead: true
            ),
            ChatMessage(
                text: "Qanday mavzu?",
                time: "10:12",
                isFromMe: true,
                isRead: true
            ),
            ChatMessage(
                text: "Present Perfect tense. Juda muhim mavzu, tayyor bo'lib kel!",
                time: "10:15",
                isFromMe: false,
                isRead: true
            ),
            ChatMessage(
                text: "Rahmat, tayyorlanaman!",
                time: "10:20",
                isFromMe: true,
                isRead: true
            ),
            ChatMessage(
                text: "Zo'r! Ko'rishguncha \u{1F44D}",
                time: "10:25",
                isFromMe: false,
                isRead: true
            ),
            ChatMessage(
                text: "Ko'rishguncha!",
                time: "10:30",
                isFromMe: true,
                isRead: false
            )
        ]
    }
}
