//
//  EnterPhoneView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 18/03/26.
//

import SwiftUI

struct EnterPhoneView: View {
    
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var phone: String = ""
    @FocusState private var isPhoneFocused: Bool
    
    private var phoneDigits: String {
        phone.filter(\.isNumber)
    }
    
    private var canSubmit: Bool {
        phoneDigits.count >= 9
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar(progress: 0.45)
                .padding(.top, 8)
                .padding(.horizontal, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Введите номер\nтелефона")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                        .padding(.top, 28)
                        .padding(.horizontal, 16)
                    
                    phoneCard
                        .padding(.top, 28)
                        .padding(.horizontal, 16)
                    
                    Spacer(minLength: 24)
                }
            }
            
            Button {
                router.push(.otp(phone: phoneDigits))
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
        .background(Color.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isPhoneFocused = true
            }
        }
    }
    
    private var phoneCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("🇺🇿")
                    .font(.system(size: 24))
                
                Text("Узбекистан")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.primaryText)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.linkPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 16)
            
            Rectangle()
                .fill(Color.separatorPrimary)
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                Text("+998")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.linkPrimary)
                
                Rectangle()
                    .fill(Color.separatorPrimary)
                    .frame(width: 1, height: 28)
                
                TextField("Введите свой номер", text: $phone)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryText)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .focused($isPhoneFocused)
                    .onChange(of: phone) { newValue in
                        phone = formatPhone(newValue)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
    }
    
    private func formatPhone(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        let limited = String(digits.prefix(9))
        
        var result = ""
        
        for (index, char) in limited.enumerated() {
            switch index {
            case 0...1:
                result.append(char)
            case 2:
                result.append(" ")
                result.append(char)
            case 3...4:
                result.append(char)
            case 5:
                result.append(" ")
                result.append(char)
            case 6:
                result.append(char)
            case 7:
                result.append(" ")
                result.append(char)
            case 8:
                result.append(char)
            default:
                break
            }
        }
        
        return result
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

#Preview("Enter phone") {
    NavigationStack {
        EnterPhoneView()
            .previewWithRouter(AppRoute.self)
    }
}


