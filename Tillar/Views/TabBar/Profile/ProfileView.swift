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
                        .padding(.top, -200)

                    VStack(spacing: 16) {
                        StatsRowView(stats: vm.stats)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)

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
        ZStack(alignment: .bottomLeading) {
            ProfileHeaderBackground()
                .frame(height: 300)

            VStack(spacing: 0) {
                Spacer()

                HStack(alignment: .bottom, spacing: 14) {
                    // Avatar circle with initials
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 72, height: 72)

                        Text(vm.initials)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if let email = vm.user?.email, !email.isEmpty {
                            Text(email)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }

                        HStack(spacing: 6) {
                            Image("coin").frame(width: 16, height: 16)
                            Text("4326")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .cornerRadius(18)
    }
}

private struct ProfileHeaderBackground: View {
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
                    .rotationEffect(.degrees(-12))
                    .offset(x: -70, y: 30)

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 220, height: 110)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -50, y: 50)

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 280, height: 140)
                    .rotationEffect(.degrees(8))
                    .offset(x: 90, y: 10)
            }
        )
    }
}

// MARK: - Stats Row

private struct StatsRowView: View {

    let stats: [ProfileViewModel.StatItem]

    var body: some View {
        HStack(spacing: 12) {
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
        case "yellow": return .yellow
        default: return .linkPrimary
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: stat.sfSymbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(stat.value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primaryText)

            Text(stat.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Menu Section

private struct MenuSection<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
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
            HStack(spacing: 14) {
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Logout Button

private struct LogoutButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Выйти из аккаунта")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.red)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
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
