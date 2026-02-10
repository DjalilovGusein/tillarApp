//
//  TranslatorView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//

import SwiftUI

struct TranslatorView: View {
    @State private var inputText: String = ""
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    HeaderView(
                        mode: vm.mode,
                        onNotificationTap: vm.openNotifications,
                        onBack: vm.closeNotifications
                    )
                    .padding(.top, -200)
                    
                    VStack(spacing: 16) {
                        languagePicker
                        inputCard
                        
                        TranslationResultCard(
                            text: "Pulimni qachon qaytarib berasan?",
                            isFavorite: true
                        )
                        
                        TranslationResultCard(
                            text: "Pulingni baribir olomisan!",
                            isFavorite: false
                        )
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 6)
            }
        }
    }

    private var languagePicker: some View {
        HStack(spacing: 14) {
            Menu("English") { }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.blue)

            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.blue)

            Menu("Russian") { }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.blue)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                TextField("Нажмите, чтобы ввести текст", text: $inputText, axis: .vertical)
                    .font(.system(size: 17, weight: .regular))
                    .lineLimit(4...6)

                Spacer()

                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.gray.opacity(0.6))
            }

            Spacer(minLength: 84)

            HStack {
                Spacer()
                Image(systemName: "mic.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.gray.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

private struct TranslationResultCard: View {
    let text: String
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Text(text)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.primaryText)
                    .lineSpacing(2)

                Spacer()

                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.blue)
            }

            HStack(spacing: 20) {
                Label("Uzbek", systemImage: "speaker.wave.2.fill")
                Label("Copy Text", systemImage: "doc.on.doc.fill")
                Spacer()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.gray.opacity(0.65))
        }
        .padding(16)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TranslatorView()
}
