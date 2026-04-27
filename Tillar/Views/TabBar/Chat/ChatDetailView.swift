//
//  ChatDetailView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

struct ChatDetailView: View {

    let room: ChatRoom
    @ObservedObject var vm: ChatViewModel
    let onBack: () -> Void
    @State private var didInitialScroll = false
    @FocusState private var isMessageFieldFocused: Bool
    
    var body: some View {
        ZStack {
            BackgroundGradient()
                .cornerRadius(32)
                .ignoresSafeArea()
                .padding(.bottom, 80)

            VStack(spacing: 0) {
                chatNavBar
                messagesArea
                    .padding(.bottom, 8)
                inputBar
            }
        }.onAppear(perform: {
            vm.markAsRead()
        })
        .hideKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Navigation Bar

    private var chatNavBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)

                Text(room.initials(for: vm.currentUserId))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(width: 36, height: 36)

                if room.isOnline(for: vm.currentUserId) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(room.displayTitle(for: vm.currentUserId))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(navSubtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }

            Spacer()

            CircleIconButton(systemName: "magnifyingglass") {
                // TODO: search in chat
            }

            CircleIconButton(systemName: "ellipsis") {
                // TODO: more options
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color.clear)
    }

    private var navSubtitle: String {
        if room.type != "GROUP" {
            return room.isOnline(for: vm.currentUserId) ? "В сети" : "Не в сети"
        } else {
            let onlineCount = room.participants.filter { $0.status == "online" }.count
            return "\(room.participants.count) участников, \(onlineCount) в сети"
        }
    }


    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(vm.messages) { message in
                        MessageBubbleLikeScreenshot(
                            message: message,
                            currentUsername: vm.currentUsername
                        )
                        .id(message.id)
                    }

                    if let typingUser = vm.typingUserInSelectedRoom {
                        TypingBubbleView(user: typingUser)
                            .id("typing_bubble")
                    }

                    Color.clear
                        .frame(height: 80)
                        .id("bottom_anchor")
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 16)
            }
            .onAppear {
                guard !didInitialScroll else { return }
                didInitialScroll = true

                DispatchQueue.main.async {
                    scrollToBottom(proxy, animated: false)
                }
            }
            .onChange(of: isMessageFieldFocused) { focused in
                if focused {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollToBottom(proxy, animated: true)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        scrollToBottom(proxy, animated: true)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("bottom_anchor", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("bottom_anchor", anchor: .bottom)
        }
    }
    
    private struct TypingBubbleView: View {
        let user: ChatUser

        var body: some View {
            HStack {
                HStack(spacing: 3) {
                    Text("печатает")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white.opacity(0.95))

                    HStack(spacing: 6) {
                        Circle()
                            .frame(width: 6, height: 6)
                        Circle()
                            .frame(width: 6, height: 6)
                        Circle()
                            .frame(width: 6, height: 6)
                    }
                    .foregroundStyle(Color.white.opacity(0.65))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(
                    maxWidth: UIScreen.main.bounds.width * 0.72,
                    alignment: .leading
                )

                Spacer(minLength: 48)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    // TODO: attach
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                HStack(spacing: 8) {
                    TextField("Сообщение", text: $vm.messageText, axis: .vertical)
                        .focused($isMessageFieldFocused)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.primaryText)
                        .lineLimit(1...4)
                        .padding(.vertical, 10)
                        .padding(.leading, 14)
                        .onChange(of: vm.messageText) { newValue in
                            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                vm.sendTyping()
                            }
                        }

                    Spacer(minLength: 0)
                }
                .background(
                    Capsule()
                        .fill(Color.primaryObject)
                        .overlay(
                            Capsule()
                                .stroke(Color.primaryObject.opacity(0.12), lineWidth: 1)
                        )
                )

                Button {
                    vm.sendMessage()
                } label: {
                    ZStack {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.58, blue: 0.88),
                                        Color(red: 0.12, green: 0.42, blue: 0.78)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)

                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: 2)
                    }
                    .frame(width: 64, height: 44)
                }
                .buttonStyle(.plain)
                .disabled(vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1.0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(
            Color.primaryObject
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: -6)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}

// MARK: - Bubble

private struct MessageBubbleLikeScreenshot: View {

    let message: ChatMessage
    let currentUsername: String

    private var isFromMe: Bool {
        message.sender.username == currentUsername
    }

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 48) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(isFromMe ? .white : .white.opacity(0.95))
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    Text(message.formattedTime)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(
                            isFromMe
                            ? Color.white.opacity(0.75)
                            : Color.white.opacity(0.65)
                        )

                    if isFromMe {
                        Image(systemName: message.isRead ? "checkmark.circle" : "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(
                maxWidth: UIScreen.main.bounds.width * 0.72,
                alignment: isFromMe ? .trailing : .leading
            )

            if !isFromMe { Spacer(minLength: 48) }
        }
    }

    private var bubbleBackground: some View {
        Group {
            if isFromMe {
                Color(red: 0.05, green: 0.15, blue: 0.30).opacity(0.75)
            } else {
                Color.white.opacity(0.28)
            }
        }
    }
}

// MARK: - Navbar circle buttons

private struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 28)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.25))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Background Gradient

private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.10, green: 0.24, blue: 0.55), location: 0.00),
                .init(color: Color(red: 0.14, green: 0.33, blue: 0.72), location: 0.45),
                .init(color: Color(red: 0.05, green: 0.16, blue: 0.40), location: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color.white.opacity(0.18), Color.white.opacity(0.0)],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 220
            )
        )
    }
}

// MARK: - Preview

#Preview("Chat Detail") {
    let vm = ChatViewModel(currentUserId: UD.authUser?.keycloakUuid ?? "")
    let mockRoom = ChatRoom(
        id: 101,
        name: nil,
        type: "direct",
        participants: [
            ChatUser(id: "1", username: "gusein", displayName: "Gusein Djalilov", status: "online"),
            ChatUser(id: "2", username: "bekzod", displayName: "Bekzod Odilboyev", status: "online")
        ],
        createdAt: "2026-03-26T10:00:00Z",
        lastMessageAt: "2026-03-26T10:30:00Z",
        unreadCount: 2
    )
    ChatDetailView(room: mockRoom, vm: vm, onBack: {})
}
