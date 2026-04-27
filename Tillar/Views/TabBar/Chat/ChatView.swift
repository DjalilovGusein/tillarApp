//
//  ChatView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/02/26.
//

import SwiftUI

struct ChatView: View {

    @StateObject private var vm = ChatViewModel(currentUserId: UD.authUser?.keycloakUuid ?? "")
    @State private var showDetail = false

    private let headerHeight: CGFloat = 250
    private let headerBottomRadius: CGFloat = 34

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .frame(height: headerHeight)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(2)

                contentCard
                    .padding(.top, 32)
                    .zIndex(1)
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let room = vm.selectedChatRoom {
                ChatDetailView(
                    room: room,
                    vm: vm,
                    onBack: {
                        showDetail = false
                        vm.loadChatRooms()
                    }
                )
            }
        }
        .onAppear {
            vm.loadChatRooms()
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

                VStack(spacing: 8) {
                    headerSearch
                    if !vm.filteredChatUsers.isEmpty && !vm.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        usersDropdown
                            .animation(.easeInOut(duration: 0.2), value: vm.filteredChatUsers.count)
                    }
                }
                .padding(.horizontal, 16)

                avatarsRow
                    .padding(.bottom, 10)
            }
            .padding(.bottom, 18)
        }
    }
    
    var usersDropdown: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.filteredChatUsers.prefix(6)) { user in
                    Button {
                        vm.selectUserFromSearch(user) { _ in
                            showDetail = vm.selectedChatRoom != nil
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.16))
                                    .frame(width: 42, height: 42)

                                Text(initials(for: user))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(user.displayName.isEmpty ? user.username : user.displayName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)

                                Text("@\(user.username)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Spacer()

                            Circle()
                                .fill(user.status.lowercased() == "online" ? Color.green : Color.gray.opacity(0.6))
                                .frame(width: 10, height: 10)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if user.id != vm.filteredChatUsers.prefix(6).last?.id {
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                            .padding(.leading, 68)
                    }
                }
            }
        }
        .frame(maxHeight: 260)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    var headerBackground: some View {
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
        .overlay(alignment: .top) {
            if !vm.filteredChatUsers.isEmpty &&
               !vm.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                usersDropdown
                    .padding(.top, 58)
                    .zIndex(999)
            }
        }
        .zIndex(999)
    }

    var avatarsRow: some View {
        // Array() wrapping avoids the ArraySlice / class-constrained error
        let users: [ChatUser] = Array(vm.chatUsers.prefix(12))
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                addAvatar

                ForEach(users) { user in
                    let title = user.displayName
                    MiniAvatarItem(
                        title: title.components(separatedBy: " ").first ?? title,
                        initials: String(user.displayName.prefix(2).uppercased()),
                        isOnline: user.isOnline
                    ).onTapGesture {
                        vm.createDirectRoom(with: user.id) { room in
                            if let room = room {
                                vm.selectChatRoom(room)
                                showDetail = true
                            }
                            
                        }
                    }
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
                        .strokeBorder(
                            Color.white.opacity(0.55),
                            style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                        )
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
    
    func initials(for user: ChatUser) -> String {
        let source = user.displayName.isEmpty ? user.username : user.displayName
        let parts = source.split(separator: " ")
        let result = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return result.isEmpty ? "?" : result.uppercased()
    }

    var contentCard: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.filteredChatRooms) { room in
                    ConversationRowLikeScreenshot(room: room, currentUserId: vm.currentUserId)
                        .onTapGesture {
                            vm.selectChatRoom(room)
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

// MARK: - Row

private struct ConversationRowLikeScreenshot: View {

    let room: ChatRoom
    let currentUserId: String

    var body: some View {
        HStack(spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(room.displayTitle(for: currentUserId))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primaryText.opacity(0.9))
                        .lineLimit(1)

                    Spacer()

                    Text(room.formattedLastMessageAt)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.primaryText.opacity(0.35))
                }

                HStack(spacing: 6) {
                    if room.unreadCount == 0 {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.blue.opacity(0.85))
                    }

                    Text(room.type == "group" ? "Group chat" : "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.primaryText.opacity(0.45))
                        .lineLimit(1)

                    Spacer()

                    if room.unreadCount > 0 {
                        Text("\(room.unreadCount)")
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

    private var avatarView: some View {
        let color = room.avatarColor(for: currentUserId)
        let online = room.isOnline(for: currentUserId)
        let initials = room.initials(for: currentUserId)

        return ZStack(alignment: .bottomLeading) {
            Circle()
                .fill(color.opacity(0.22))
                .frame(width: 54, height: 54)

            Text(initials)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 54, height: 54)

            if online {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 6, y: -2)
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

#Preview("Chat List") {
    ChatView().environmentObject(TabBarViewModel())
}
