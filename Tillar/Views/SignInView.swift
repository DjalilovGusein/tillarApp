//
//  SignInView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/10/25.
//

import SwiftUI

struct SignInView: View {

    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel = AuthViewModel()

    @State private var login: String = ""
    @State private var password: String = ""

    var canSubmit: Bool {
        !login.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: – Logo & Title
                VStack(spacing: 16) {
                    Image("tillarLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                    VStack(spacing: 6) {
                        Text("Войти")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color.primaryText)

                        Text("Введите данные для входа в аккаунт")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 52)
                .padding(.bottom, 36)
                .padding(.horizontal, 24)

                // MARK: – Form
                VStack(spacing: 14) {
                    LabeledField(
                        text: $login,
                        placeholder: "Логин или Email",
                        contentType: .username,
                        keyboardType: .emailAddress,
                        isSecure: false
                    )

                    VStack(spacing: 8) {
                        LabeledField(
                            text: $password,
                            placeholder: "Пароль",
                            contentType: .password,
                            keyboardType: .default,
                            isSecure: true
                        )

                        if let error = viewModel.errorText {
                            ErrorText(error)
                        }
                    }

                    HStack {
                        Spacer()
                        Button {
                            router.push(.forgotPassword)
                        } label: {
                            Text("Забыли пароль?")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.linkPrimary)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // MARK: – Login Button
                Button {
                    viewModel.login(username: login, password: password)
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Войти")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryFillButtonStyle())
                .disabled(!canSubmit || viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.top, 24)

                // MARK: – Divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.separatorPrimary)
                        .frame(height: 1)
                    Text("или")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.tertiaryText)
                        .fixedSize()
                    Rectangle()
                        .fill(Color.separatorPrimary)
                        .frame(height: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)

                // MARK: – Social Buttons
                VStack(spacing: 12) {
                    Button {
                        // Google sign in
                    } label: {
                        HStack(spacing: 10) {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Войти через Google")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .padding(.horizontal, 16)

                    Button {
                        // Apple sign in
                    } label: {
                        HStack(spacing: 10) {
                            Image("appleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Войти через Apple")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .padding(.horizontal, 16)
                }

                // MARK: – Register Link
                HStack(spacing: 4) {
                    Text("Нет аккаунта?")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.tertiaryText)
                    Button {
                        router.push(.createAccount)
                    } label: {
                        Text("Зарегистрироваться")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.linkPrimary)
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(Color.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.user) { _, user in
            if user != nil {
                router.popToRoot()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .previewWithRouter(AppRoute.self)
    }
}
