//
//  HomeView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 05/01/26.
//

import SwiftUI

// MARK: - Home

struct HomeView: View {

    private let categories: [CategoryItem] = [
        .init(title: "Уроки", sfSymbol: "book.closed.fill", color: .red),
        .init(title: "Фразы", sfSymbol: "bubble.left.and.bubble.right.fill", color: .green),
        .init(title: "Слова", sfSymbol: "doc.text.fill", color: .orange),
        .init(title: "Курсы\nПлюс", sfSymbol: "graduationcap.fill", color: .blue),
        .init(title: "Игры", sfSymbol: "gamecontroller.fill", color: .purple)
    ]

    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    HeaderView(
                        mode: vm.mode,
                        onNotificationTap: vm.openNotifications,
                        onBack: vm.closeNotifications
                    )
                    .padding(.top, -200)

                    Group {
                        switch vm.mode {
                        case .home:
                            HomeContent(categories: categories)

                        case .notifications:
                            NotificationsContent(vm: vm.notificationsVM, onBack: vm.closeNotifications)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Spacer(minLength: 100) // Extra space for FAB
                }
                .padding(.top, 6)
            }

            // Floating Action Button
            if vm.mode == .home {
                FloatingActionButton {
                    // TODO: Add action
                }
            }
        }
    }
}

private struct NotificationsContent: View {

    @ObservedObject var vm: NotificationsViewModel
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.85))
                        .frame(width: 33, height: 33)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
                        )
                }
                Spacer()
                Text("Уведомления")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            ForEach(vm.items) { item in
                NotificationCell(
                    item: item,
                    isExpanded: vm.isExpanded(item),
                    onToggle: { vm.toggle(item) }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct NotificationCell: View {

    let item: AppNotification
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 10) {

            HStack(alignment: .top, spacing: 12) {
                avatar

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.primaryText)

                        Spacer()

                        Text(item.time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.tertiaryText)
                    }

                    Text(item.message)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.tertiaryText)
                        .lineLimit(isExpanded ? 4 : 2)
                }
            }

            if isExpanded {
                expandedContent
            }

            HStack {
                Spacer()
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.linkPrimary)
                        .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 8)
    }

    private var avatar: some View {
        ZStack(alignment: .topTrailing) {
            Image(item.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if item.isUnread {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 3, y: -3)
            }
        }
    }

    @ViewBuilder
    private var expandedContent: some View {
        switch item.payload {
        case .none:
            EmptyView()

        case let .progress(title, subtitle, scoreText, imageName):
            ProgressInlineCard(
                title: title,
                subtitle: subtitle,
                scoreText: scoreText,
                imageName: imageName
            )
        }
    }
}

private struct ProgressInlineCard: View {
    let title: String
    let subtitle: String
    let scoreText: String
    let imageName: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                HStack(alignment: .bottom, spacing: 10) {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(scoreText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 86, height: 86)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color.linkPrimary.opacity(0.95),
                    Color.linkPrimary.opacity(0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Home Content (your current blocks)

private struct HomeContent: View {

    let categories: [CategoryItem]

    var body: some View {
        VStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 10) {
                Text("Категории")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primaryText)

                CategoryRow(items: categories)
            }
            .padding(.horizontal, 16)

            ProgressCard()
                .padding(.horizontal, 16)

            Text("Мой прогресс")
                .font(.footnote)
                .foregroundStyle(Color.tertiaryText)

            VStack(alignment: .leading, spacing: 12) {
                Text("Последние просмотренные уроки")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primaryText)

                LessonCard(
                    title: "English Master Class Le…",
                    subtitle: "13 Sections • 4 Hours",
                    price: "$9",
                    teacher: "Richard Wu"
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Floating Action Button

private struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.linkPrimary,
                                        Color.linkPrimary.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.linkPrimary.opacity(0.4), radius: 12, x: 0, y: 6)

                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(FABButtonStyle())
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Header

private struct HeaderView: View {

    let mode: HomeMode
    let onNotificationTap: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeaderBackground()
                .frame(height: 300)

            VStack {
                Image("tillarLogo")
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.top, 12)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bekzod.O")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        HStack(spacing: 8) {
                            Image("coin").frame(width: 18, height: 18)

                            Text("4326")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    Spacer()

                    if mode == .notifications {
                        BackButton(action: onBack)
                    } else {
                        NotificationButton(action: onNotificationTap)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .cornerRadius(18)
    }
}

private struct HeaderBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.linkPrimary.opacity(0.85),
                Color.linkPrimary.opacity(0.95),
                Color.linkPrimary.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 280, height: 140)
                    .rotationEffect(.degrees(8))
                    .offset(x: 90, y: 10)

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 300, height: 150)
                    .rotationEffect(.degrees(8))
                    .offset(x: 70, y: 20)

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 320, height: 160)
                    .rotationEffect(.degrees(8))
                    .offset(x: 50, y: 30)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

private struct NotificationButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 54, height: 54)
                    .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)

                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))

                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 10, y: -10)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 54, height: 54)
                    .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)

                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))
                
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 10, y: -10)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Categories

private struct CategoryRow: View {
    let items: [CategoryItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    CategoryTile(item: item)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

private struct CategoryTile: View {
    let item: CategoryItem

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

                VStack {
                    Image(systemName: item.sfSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(item.color)

                    Text(item.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primaryText.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .frame(width: 78, height: 90)
    }
}

private struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let sfSymbol: String
    let color: Color
}

// MARK: - Progress card

private struct ProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Мой прогресс")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                MiniProgressTile(
                    title: "Вы прошли\nкурс",
                    valueBig: "50%",
                    subtitle: "Beginner"
                )

                MiniBarsTile(
                    title: "Вы провели на платформе\n32 часа за последние\n2 недели"
                )
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.linkPrimary.opacity(0.95),
                    Color.linkPrimary.opacity(0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct MiniProgressTile: View {
    let title: String
    let valueBig: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Ring(progress: 0.5)
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }

            Text(valueBig)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct MiniBarsTile: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(3)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<12, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(i == 8 ? Color.green.opacity(0.95) : Color.white.opacity(0.35))
                        .frame(width: 8, height: CGFloat([10, 16, 22, 14, 28, 18, 24, 12, 34, 20, 26, 16][i]))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct Ring: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 9)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Lesson card

private struct LessonCard: View {
    let title: String
    let subtitle: String
    let price: String
    let teacher: String

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.background)
                    .frame(height: 170)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.08), Color.black.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.black.opacity(0.15))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(String(teacher.prefix(1)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                )

                            Text(teacher)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(.bottom, 6)

                        Spacer()
                    }

                    Spacer()

                    Text(price)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(10)
                }
                .padding(12)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primaryText)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primaryText)
                }

                Spacer()

                Button {
                    // TODO: start lesson
                } label: {
                    HStack(spacing: 6) {
                        Text("Let's practice 🔥")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.accentIcon)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Other tabs (placeholders)

struct CoursesView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            Text("Курсы")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primaryText)
        }
    }
}

struct ProgressViewScreen: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            Text("Прогресс")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primaryText)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            Text("Профиль")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primaryText)
        }
    }
}

// MARK: - Preview

#Preview("Home View") {
    HomeView()
}

#Preview("Home View - Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}

#Preview("Courses View") {
    CoursesView()
}

#Preview("Progress View") {
    ProgressViewScreen()
}

#Preview("Profile View") {
    ProfileView()
}
