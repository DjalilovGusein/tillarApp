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
        }
        .hideKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Navigation Bar (like screenshots)

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

            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)

                Text(conversation.initials)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(width: 36, height: 36)

                // online dot (for personal chat)
                if conversation.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Подзаголовок как на скринах
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
        // Если у тебя есть разные типы диалога — подставь свою логику.
        // Сейчас: online -> как на личном чате, иначе как на группе (пример).
        if conversation.isOnline {
            return "Был онлайн в 14:30" // подставь реальное поле, если есть
        } else {
            return "6 участников, 4 в сети" // подставь реальное поле, если есть
        }
    }

    // MARK: - Messages

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(vm.messages) { message in
                        MessageBubbleLikeScreenshot(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 32)
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

    // MARK: - Input Bar (like screenshots)

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
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.primaryText)
                        .lineLimit(1...4)
                        .padding(.vertical, 10)
                        .padding(.leading, 14)
                    
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
                            .offset(x: 2) // визуальный баланс
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

// MARK: - Bubble (like screenshots)

private struct MessageBubbleLikeScreenshot: View {

    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 48) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(message.isFromMe ? .white : .white.opacity(0.95))
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    Text(message.time)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(
                            message.isFromMe
                            ? Color.white.opacity(0.75)
                            : Color.white.opacity(0.65)
                        )

                    if message.isFromMe {
                        Image(systemName: message.isRead ? "checkmark" : "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: message.isFromMe ? .trailing : .leading)

            if !message.isFromMe { Spacer(minLength: 48) }
        }
    }

    private var bubbleBackground: some View {
        Group {
            if message.isFromMe {
                Color(red: 0.05, green: 0.15, blue: 0.30).opacity(0.75) // темный как на скрине
            } else {
                Color.white.opacity(0.28) // светлый полупрозрачный
            }
        }
    }
}

// MARK: - Small circle buttons in navbar

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

#Preview("Chat Detail (New)") {
    ChatDetailView(
        conversation: Conversation(
            name: "Bekzod Odilboyev",
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

