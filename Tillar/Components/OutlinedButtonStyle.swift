//
//  OutlinedButtonStyle.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//

import SwiftUI

struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.separatorPrimary, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .foregroundStyle(.primary)
            .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
