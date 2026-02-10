//
//  CustomTabBar.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//

import SwiftUI
import Foundation

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(
            TopRoundedRectangle(radius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -2)
        )
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = (selection == tab)
        
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 6) {
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isSelected ? Color.primaryIcon : Color.gray.opacity(0.6))
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.primaryIcon : Color.gray.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
