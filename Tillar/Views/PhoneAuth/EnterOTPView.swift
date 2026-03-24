//
//  EnterOTPView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 18/03/26.
//

import SwiftUI


struct EnterOTPView: View {
    
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel = AuthViewModel()
    
    let phone: String
    
    @State private var otpText: String = ""
    @FocusState private var isCodeFocused: Bool
    
    private let codeLength = 6
    
    private var canSubmit: Bool {
        otpText.count == codeLength
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar(progress: 0.72)
                .padding(.top, 8)
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Подтвердите свой\nномер телефона")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .padding(.top, 28)
                    .padding(.horizontal, 16)
                
                Text("Пожалуйста введите код, который мы отправили\nна номер \(phone)")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.tertiaryText)
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                
                otpBoxes
                    .padding(.top, 28)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 4) {
                    Text("Не получили код?")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.primaryText)
                    
                    Button {
                        // resend code
                    } label: {
                        Text("Отправить повторно.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.linkPrimary)
                    }
                }
                .padding(.top, 22)
                .padding(.horizontal, 16)
                
                if let error = viewModel.errorText {
                    ErrorText(error)
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                }
                
                Spacer()
                
                Button {
                    router.push(.tabBar)
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Дальше")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryFillButtonStyle())
                .disabled(!canSubmit || viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            
            ZStack {
                TextField("", text: $otpText)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isCodeFocused)
                    .opacity(0.01)
                    .frame(width: 1, height: 1)
                    .onChange(of: otpText) { newValue in
                        let digits = newValue.filter(\.isNumber)
                        otpText = String(digits.prefix(codeLength))
                    }
            }
            .frame(height: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isCodeFocused = true
        }
        .background(Color.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isCodeFocused = true
            }
        }
    }
    
    private var otpBoxes: some View {
        HStack(spacing: 10) {
            ForEach(0..<codeLength, id: \.self) { index in
                let digit = character(at: index)
                let isFilled = digit != nil
                let isCurrent = otpText.count == index
                
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.primaryObject)
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isCurrent ? Color.linkPrimary.opacity(0.35) : Color.clear, lineWidth: 1.5)
                        )
                    
                    if isFilled {
                        Circle()
                            .fill(Color.linkPrimary)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func character(at index: Int) -> String? {
        guard index < otpText.count else { return nil }
        let array = Array(otpText)
        return String(array[index])
    }
    
    private func topBar(progress: CGFloat) -> some View {
        HStack(spacing: 16) {
            Button {
                router.pop()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryObject)
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                }
            }
            
            ProgressView(value: progress)
                .tint(Color.linkPrimary)
                .frame(maxWidth: 180)
            
            Spacer()
        }
    }
}

#Preview("Enter OTP") {
    NavigationStack {
        EnterOTPView(phone: "+998 90 000 46 07")
            .previewWithRouter(AppRoute.self)
    }
}
