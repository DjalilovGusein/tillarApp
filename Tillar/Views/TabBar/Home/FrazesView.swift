//
//  FrazesView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 10/03/26.
//

import SwiftUI

struct FrazesContent: View {

    @ObservedObject var vm: FrazesViewModel
    let onBack: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        VStack(spacing: 14) {
            header

            if vm.isLoading {
                ProgressView()
                    .padding(.top, 40)

            } else if let errorText = vm.errorText {
                VStack(spacing: 10) {
                    Text("Не удалось загрузить фразы")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primaryText)

                    Text(errorText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.tertiaryText)
                        .multilineTextAlignment(.center)

                    Button("Повторить") {
                        vm.getFrazes()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.linkPrimary)
                    .clipShape(Capsule())
                }
                .padding(.top, 40)
                .padding(.horizontal, 16)

            } else if vm.frazes.isEmpty {
                Text("Фразы пока недоступны")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.tertiaryText)
                    .padding(.top, 40)

            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(Array(vm.frazes.enumerated()), id: \.offset) { _, fraze in
                        FrazeCategoryCard(fraze: fraze)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var header: some View {
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

            Text("Фразы")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)

            Spacer()

            Color.clear
                .frame(width: 33, height: 33)
        }
    }
}

struct FrazeCategoryCard: View {
    let fraze: Fraze

    var body: some View {
        Button {
            // TODO: открыть список фраз внутри категории
        } label: {
            VStack(spacing: 12) {
                frazeIcon

                Text(fraze.name ?? "Без названия")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
            .frame(height: 110)
            .background(Color.primaryObject)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var frazeIcon: some View {
        if let iconUrl = fraze.iconUrl,
           let url = URL(string: iconUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderIcon
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholderIcon
                @unknown default:
                    placeholderIcon
                }
            }
            .frame(width: 52, height: 52)
        } else {
            placeholderIcon
        }
    }

    private var placeholderIcon: some View {
        Image(systemName: "text.bubble")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundStyle(Color.linkPrimary.opacity(0.7))
    }
}

#Preview {
    FrazesContent(vm: FrazesViewModel(), onBack: { })
}
