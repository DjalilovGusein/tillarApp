//
//  ProfileView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 13/02/26.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = ProfileViewModel()
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ProfileHeaderView(vm: vm)

                    VStack(spacing: 12) {
                        StatsRowView(stats: vm.stats)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        MenuSection(title: "Аккаунт") {
                            MenuRow(sfSymbol: "person.fill",
                                    color: .blue,
                                    title: "Личные данные") {}
                            Divider().padding(.leading, 52)
                            MenuRow(sfSymbol: "bell.fill",
                                    color: .orange,
                                    title: "Уведомления") {}
                            Divider().padding(.leading, 52)
                            MenuRow(sfSymbol: "globe",
                                    color: .green,
                                    title: "Язык приложения") {}
                        }
                        .padding(.horizontal, 16)

                        MenuSection(title: "Обучение") {
                            MenuRow(sfSymbol: "chart.bar.fill",
                                    color: .purple,
                                    title: "Мой прогресс") {}
                            Divider().padding(.leading, 52)
                            MenuRow(sfSymbol: "trophy.fill",
                                    color: .yellow,
                                    title: "Достижения") {}
                            Divider().padding(.leading, 52)
                            MenuRow(sfSymbol: "bookmark.fill",
                                    color: .red,
                                    title: "Сохранённые уроки") {}
                        }
                        .padding(.horizontal, 16)

                        MenuSection(title: "Поддержка") {
                            MenuRow(sfSymbol: "questionmark.circle.fill",
                                    color: .teal,
                                    title: "Помощь и поддержка") {}
                            Divider().padding(.leading, 52)
                            MenuRow(sfSymbol: "star.fill",
                                    color: .yellow,
                                    title: "Оценить приложение") {}
                        }
                        .padding(.horizontal, 16)

                        LogoutButton {
                            vm.logout()
                            router.popToRoot()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .onAppear { vm.loadUserInfo() }
    }
}

// MARK: - Header

private struct ProfileHeaderView: View {

    @ObservedObject var vm: ProfileViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.linkPrimary, Color.linkPrimary.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 220, height: 220)
                .offset(x: -100, y: -60)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 160, height: 160)
                .offset(x: 130, y: 20)

            // Content
            VStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 88, height: 88)

                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 76, height: 76)

                    Text(vm.initials)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 56)

                // Name
                Text(vm.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Email
                if let email = vm.user?.email, !email.isEmpty {
                    Text(email)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }

                // Coin badge
                HStack(spacing: 5) {
                    Image("coin")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("4326")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 260)
    }
}

// MARK: - Stats Row

private struct StatsRowView: View {

    let stats: [ProfileViewModel.StatItem]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(stats) { stat in
                StatCard(stat: stat)
            }
        }
    }
}

private struct StatCard: View {

    let stat: ProfileViewModel.StatItem

    private var iconColor: Color {
        switch stat.color {
        case "orange": return .orange
        case "yellow": return Color(red: 0.95, green: 0.77, blue: 0.06)
        default: return .linkPrimary
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: stat.sfSymbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(stat.value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primaryText)

            Text(stat.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Menu Section

private struct MenuSection<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.4)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
    }
}

private struct MenuRow: View {

    let sfSymbol: String
    let color: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiaryText.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Logout Button

private struct LogoutButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Выйти из аккаунта")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.red)
            .padding(.vertical, 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Profile View") {
    ProfileView()
        .environmentObject(Router<AppRoute>())
}

#Preview("Profile View - Dark") {
    ProfileView()
        .environmentObject(Router<AppRoute>())
        .preferredColorScheme(.dark)
}
