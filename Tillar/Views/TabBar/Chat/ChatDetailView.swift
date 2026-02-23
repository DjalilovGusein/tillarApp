//
//  ChatDetailView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

struct ChatDetailView: View {

    let conversation: Conversation
    @ObservedObject var vm: ChatViewModel
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                chatNavBar
                messagesArea
                inputBar
            }
        }
        .hideKeyboardOnTap()
    }

    // MARK: - Navigation Bar

    private var chatNavBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primaryText)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    )
            }
            .buttonStyle(.plain)

            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(conversation.avatarColor.opacity(0.2))

                    Text(conversation.initials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(conversation.avatarColor)
                }
                .frame(width: 42, height: 42)

                if conversation.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primaryText)

                Text(conversation.isOnline ? "В сети" : "Был(а) недавно")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(conversation.isOnline ? Color.green : Color.tertiaryText)
            }

            Spacer()

            Button {
                // TODO: voice call
            } label: {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.linkPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Button {
                // TODO: more options
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.tertiaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Messages

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 6) {
                    dateSeparator("Сегодня")

                    ForEach(vm.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .onChange(of: vm.messages.count) { _ in
                if let last = vm.messages.last {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func dateSeparator(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.tertiaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.fieldBackground)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button {
                // TODO: attach file / photo
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.tertiaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.fieldBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                TextField("Сообщение...", text: $vm.messageText, axis: .vertical)
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(1...4)
                    .foregroundStyle(.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Button(action: vm.sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(
                        vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.tertiaryText
                            : Color.linkPrimary
                    )
            }
            .buttonStyle(.plain)
            .disabled(vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: -2)
        )
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {

    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 60) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(message.isFromMe ? .white : .primaryText)

                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(
                            message.isFromMe
                                ? Color.white.opacity(0.7)
                                : Color.tertiaryText
                        )

                    if message.isFromMe {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                message.isFromMe
                    ? Color.linkPrimary
                    : Color.white
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: .black.opacity(message.isFromMe ? 0 : 0.05), radius: 4, x: 0, y: 2)

            if !message.isFromMe { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Preview

#Preview("Chat Detail") {
    ChatDetailView(
        conversation: Conversation(
            name: "Bekzod.O",
            initials: "BO",
            avatarColor: .blue,
            lastMessage: "Salom!",
            time: "10:30",
            unreadCount: 2,
            isOnline: true
        ),
        vm: ChatViewModel(),
        onBack: {}
    )
}
