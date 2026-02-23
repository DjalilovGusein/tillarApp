//
//  ChatView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

// MARK: - Chat List

struct ChatView: View {

    @StateObject private var vm = ChatViewModel()
    @State private var showDetail = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                chatHeader
                searchBar
                conversationsList
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let conversation = vm.selectedConversation {
                ChatDetailView(
                    conversation: conversation,
                    vm: vm,
                    onBack: { showDetail = false }
                )
            }
        }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack {
            Text("Чат")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primaryText)

            Spacer()

            Button {
                // TODO: compose new message
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)

                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.linkPrimary)
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.tertiaryText)

            TextField("Поиск...", text: $vm.searchText)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Conversations List

    private var conversationsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.filteredConversations) { conversation in
                    ConversationRow(conversation: conversation)
                        .onTapGesture {
                            vm.selectConversation(conversation)
                            showDetail = true
                        }

                    Divider()
                        .padding(.leading, 76)
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Conversation Row

private struct ConversationRow: View {

    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primaryText)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.time)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.tertiaryText)
                }

                HStack {
                    Text(conversation.lastMessage)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.tertiaryText)
                        .lineLimit(1)

                    Spacer()

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 22, minHeight: 22)
                            .background(Color.linkPrimary)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(conversation.avatarColor.opacity(0.2))

                Text(conversation.initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(conversation.avatarColor)
            }
            .frame(width: 52, height: 52)

            if conversation.isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
}

// MARK: - Preview

#Preview("Chat List") {
    ChatView()
}
