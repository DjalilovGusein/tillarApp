//
//  ProfileView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 13/02/26.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = ProfileViewModel()
    @EnvironmentObject private var tabBarVM: TabBarViewModel
    @EnvironmentObject private var router: Router<AppRoute>

    @AppStorage("tillar_dark_mode") private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    ProfileWaveHeaderView(
                        initials: "\(tabBarVM.user?.user?.firstName ?? "") \(tabBarVM.user?.user?.lastName?.prefix(1) ?? "").",
                        coins: "\(tabBarVM.coins?.data?.first?.amount ?? 0)"
                    )
                    .padding(.top, -90)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(vm.displayName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.primaryText)
                                    .lineLimit(1)
                                Image("statusFree")
                                    .padding(.leading, -5)
                            }
                            Text(tabBarVM.user?.user?.email ?? "")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.tertiaryText)
                                .lineLimit(1)
                        }.padding(.leading, 16)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 3)
                                
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.primaryText)
                            }
                            .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 16)
                    }

                    ProBannerView(
                        title: "Подписка PRO",
                        subtitle: "Выберите один из трех тарифов.",
                        buttonTitle: "Выбрать",
                        onTap: {
                            // TODO: router.push(.pro)
                        }
                    )
                    .padding(.horizontal, 16)

                    ProfileMenuCard {
                        ProfileMenuRow(
                            icon: "book.closed",
                            title: "Мои уроки",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileMenuRow(
                            icon: "chart.xyaxis.line",
                            title: "Мой прогресс",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileMenuRow(
                            icon: "bookmark",
                            title: "Избранные",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileMenuRow(
                            icon: "cart",
                            title: "Магазин",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileToggleRow(
                            icon: "moon",
                            title: "Темный режим",
                            isOn: $isDarkMode
                        )
                    }
                    .padding(.horizontal, 16)

                    ProfileMenuCard {
                        ProfileMenuRow(
                            icon: "creditcard",
                            title: "Оплата",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileMenuRow(
                            icon: "headphones",
                            title: "Служба Поддержки",
                            onTap: { /* TODO */ }
                        )
                        DividerInset()

                        ProfileMenuRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Выйти",
                            titleColor: .red,
                            iconColor: .red,
                            onTap: {
                                vm.logout()
                                router.popToRoot()
                            }
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 110)
                }
            }
        }
        .onAppear { vm.loadUserInfo() }
    }
}

// MARK: - Header (Wave)

private struct ProfileWaveHeaderView: View {

    let initials: String
    let coins: String

    var body: some View {
        ZStack(alignment: .top) {
            Image("tillarLogo")
                .padding(.top, 80)
                .foregroundStyle(.white)
                .zIndex(100)
            VStack {
                HStack(alignment: .center, spacing: 12) {
                    AvatarView(initials: initials)
                        .padding(.leading, 16)
                    Spacer()
                    HStack(spacing: 10) {
                        SocialIcon("paperplane.fill")
                        SocialIcon("camera.fill")
                        SocialIcon("xmark")
                        SocialIcon("f.cursive")
                        Spacer()
                        
                        CoinPill(coins: coins)
                    }
                }
                .padding(.top, 112)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black)
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
            }
            .frame(height: 220)
        }
    }

    private struct SocialIcon: View {
        let systemName: String
        init(_ systemName: String) { self.systemName = systemName }

        var body: some View {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
        }
    }

    private struct CoinPill: View {
        let coins: String

        var body: some View {
            HStack() {
                Image("coin")
                    .frame(width: 30, height: 30)

                Text(coins)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.leading, -10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private struct AvatarView: View {
        let initials: String

        var body: some View {
            ZStack {
                Circle()
                    .fill(.blue)
                Text(initials.isEmpty ? "R" : initials.prefix(1))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primaryText)
            }
            .frame(width: 86, height: 86)
            .padding(.bottom, -30)
        }
    }
}


// MARK: - PRO Banner

private struct ProBannerView: View {

    let title: String
    let subtitle: String
    let buttonTitle: String
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Button(action: onTap) {
                Text(buttonTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color.white.opacity(0.18))
                    )
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.32, blue: 0.98),
                    Color(red: 0.08, green: 0.65, blue: 0.98)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Menu Card

private struct ProfileMenuCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

private struct DividerInset: View {
    var body: some View {
        Divider()
            .padding(.leading, 50)
    }
}

private struct ProfileMenuRow: View {

    let icon: String
    let title: String
    var titleColor: Color = .primaryText
    var iconColor: Color = .primaryText
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(iconColor)
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(titleColor)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.tertiaryText.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileToggleRow: View {

    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color.primaryText)
                .frame(width: 22)

            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.primaryText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.linkPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview("Profile") {
    ProfileView()
        .environmentObject(TabBarViewModel())
        .environmentObject(Router<AppRoute>())
}
