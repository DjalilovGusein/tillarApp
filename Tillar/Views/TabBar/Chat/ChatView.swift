//
//  ChatView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

struct ChatView: View {

    @StateObject private var vm = ChatViewModel()
    @State private var showDetail = false

    // Header tuning
    private let headerHeight: CGFloat = 250
    private let headerBottomRadius: CGFloat = 34

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack {
                    header
                        .frame(height: headerHeight)
                        .ignoresSafeArea(edges: .top)
                    contentCard
                        .padding(.top,)
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
}

// MARK: - Header

private extension ChatView {

    var header: some View {
        ZStack(alignment: .bottom) {
            headerBackground

            VStack(spacing: 14) {
                topBar
                    .padding(.top, 80)

                headerSearch
                    .padding(.horizontal, 16)

                avatarsRow
                    .padding(.bottom, 10)
            }
            .padding(.bottom, 18)
        }
    }

    var headerBackground: some View {
        // gradient similar to screenshot
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.09, green: 0.22, blue: 0.55), location: 0.00),
                .init(color: Color(red: 0.12, green: 0.30, blue: 0.70), location: 0.45),
                .init(color: Color(red: 0.06, green: 0.18, blue: 0.45), location: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // subtle light blob top-left (like iOS blur highlight)
            RadialGradient(
                colors: [Color.white.opacity(0.20), Color.white.opacity(0.0)],
                center: .topLeading,
                startRadius: 10,
                endRadius: 190
            )
        )
        .clipShape(RoundedCorner(radius: headerBottomRadius, corners: [.bottomLeft, .bottomRight]))
    }

    var topBar: some View {
        ZStack {
            Image("tillarLogo")
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundStyle(.white)

            HStack {
                Spacer()
                Button {
                    // TODO: dropdown / filter
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 6)
            }
        }
        .padding(.horizontal, 16)
    }

    var headerSearch: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))

            TextField("Поиск...", text: $vm.searchText)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.white.opacity(0.18))
        .clipShape(Capsule())
    }

    var avatarsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                addAvatar

                // можно заменить на vm.suggestedContacts / recentContacts,
                // пока просто берем первые N из filteredConversations
                ForEach(Array(vm.filteredConversations.prefix(12))) { c in
                    MiniAvatarItem(
                        title: c.name.components(separatedBy: " ").first ?? c.name,
                        initials: c.initials,
                        isOnline: c.isOnline
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    var addAvatar: some View {
        Button {
            // TODO: add / new chat
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                        .frame(width: 52, height: 52)

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Text("Добавить")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Content card (list)

private extension ChatView {

    var contentCard: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            LazyVStack(spacing: 0) {
                ForEach(vm.filteredConversations) { conversation in
                    ConversationRowLikeScreenshot(conversation: conversation)
                        .onTapGesture {
                            vm.selectConversation(conversation)
                            showDetail = true
                        }
                    
                    Divider()
                        .padding(.leading, 78)
                }
            }
            .padding(.bottom, 120)
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.background)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: -2)
        .padding(.horizontal, 0)
        .padding(.vertical, -60)
        
    }
}

// MARK: - Row like screenshot

private struct ConversationRowLikeScreenshot: View {

    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primaryText.opacity(0.9))
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.time)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.primaryText.opacity(0.35))
                }

                HStack(spacing: 6) {
                    // если у тебя есть "isDelivered/hasRead" — тут можно показать галочки
                    if conversation.unreadCount == 0 {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.blue.opacity(0.85))
                    }

                    Text(conversation.lastMessage)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.primaryText.opacity(0.45))
                        .lineLimit(1)

                    Spacer()

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 22, minHeight: 22)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        ZStack(alignment: .bottomLeading) {
            Circle()
                .fill(conversation.avatarColor.opacity(0.22))
                .frame(width: 54, height: 54)

            Text(conversation.initials)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(conversation.avatarColor)
                .frame(width: 54, height: 54)

            if conversation.isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 6, y: -2) // ближе к низу слева как на скрине
            }
        }
    }
}

// MARK: - Mini avatar item (top row)

private struct MiniAvatarItem: View {
    let title: String
    let initials: String
    let isOnline: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 52, height: 52)

                Text(initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(width: 52, height: 52)

                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 11, height: 11)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
        }
        .frame(width: 64)
    }
}

// MARK: - Rounded corners helper

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview("Chat List (Like Screenshot)") {
    ChatView().environmentObject(TabBarViewModel())
}
