//
//  SignUpView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 26/02/26.
//

import SwiftUI

struct SignUpView: View {

    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel = AuthViewModel()

    @State private var surname: String = ""
    @State private var name: String = ""
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: - Logo & Title
                VStack(spacing: 14) {
                    // На макете сверху именно текстовый логотип.
                    Image("tillarLogo")
                        .foregroundStyle(Color.linkPrimary)
                        .padding(.top, 8)

                    VStack(spacing: 6) {
                        Text("Зарегистрироваться")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color.primaryText)

                        Text("Введите адрес электронной почты и пароль\nдля создания аккаунта.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 36)
                .padding(.bottom, 22)
                .padding(.horizontal, 24)

                // MARK: - Form
                VStack(spacing: 12) {
                    
                    LabeledField(
                        text: $phoneNumber,
                        placeholder: "Номер телефона",
                        contentType: .telephoneNumber,
                        keyboardType: .phonePad,
                        isSecure: false
                    )
                    
                    LabeledField(
                        text: $surname,
                        placeholder: "Фамилия",
                        contentType: .name,
                        keyboardType: .default,
                        isSecure: false
                    )
                    
                    LabeledField(
                        text: $name,
                        placeholder: "Имя",
                        contentType: .name,
                        keyboardType: .default,
                        isSecure: false
                    )

                    LabeledField(
                        text: $userName,
                        placeholder: "Имя пользователя",
                        contentType: .username,
                        keyboardType: .default,
                        isSecure: false
                    )

                    LabeledField(
                        text: $email,
                        placeholder: "E-mail",
                        contentType: .emailAddress,
                        keyboardType: .emailAddress,
                        isSecure: false
                    )

                    VStack(spacing: 8) {
                        LabeledField(
                            text: $password,
                            placeholder: "Password",
                            contentType: .newPassword,
                            keyboardType: .default,
                            isSecure: true
                        )

                        if let error = viewModel.errorText {
                            ErrorText(error)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // MARK: - Next Button
                Button {
                    viewModel.register(username: userName, password: password, email: email, firstName: name, lastName: surname,phoneNumber: "998\(phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: ""))") { response in
                        guard let isSuccess = response.success else { return }
                        if isSuccess {
                            self.router.push(.otp(phone: "998\(phoneNumber)"))
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Дальше")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryFillButtonStyle())
                .disabled(!canSubmit || viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.top, 18)

                // MARK: - Divider (account exists)
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.separatorPrimary)
                        .frame(height: 1)

                    Text("У вас уже есть аккаунт?")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.tertiaryText)
                        .fixedSize()

                    Rectangle()
                        .fill(Color.separatorPrimary)
                        .frame(height: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)

                // MARK: - Social / Login Buttons
                VStack(spacing: 12) {

                    Button {
                        // TODO: login by email
                        router.pop()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Войти по почте")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .padding(.horizontal, 16)

                    Button {
                        // TODO: apple sign-in
                    } label: {
                        HStack(spacing: 10) {
                            Image("appleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Войти с помощью Apple")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .padding(.horizontal, 16)

                    Button {
                        // TODO: google sign-in
                    } label: {
                        HStack(spacing: 10) {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Войти с помощью Google")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .padding(.horizontal, 16)
                }

                // MARK: - Legal
                Text("Нажимая кнопку «Продолжить», я подтверждаю,\nчто ознакомился с условиями соглашения и политикой\nконфиденциальности и ними.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                    .padding(.horizontal, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primaryObject)
                    .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
            )
            .padding(16)
        }
        .background(Color.background.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .previewWithRouter(AppRoute.self)
    }
}
