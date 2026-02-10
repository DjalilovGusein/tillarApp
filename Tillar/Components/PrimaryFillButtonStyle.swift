//
//  PrimaryFillButtonStyle.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//

import SwiftUI

struct PrimaryFillButtonStyle: ButtonStyle {
    var enabledColor: Color = Color.accentIcon
    var disabledColor: Color = .gray.opacity(0.3)
    
    func makeBody(configuration: Configuration) -> some View {
        PrimaryFillButton(configuration: configuration,
                          enabledColor: enabledColor,
                          disabledColor: disabledColor)
    }
    
    private struct PrimaryFillButton: View {
        @Environment(\.isEnabled) private var isEnabled
        let configuration: ButtonStyle.Configuration
        let enabledColor: Color
        let disabledColor: Color
        
        var body: some View {
            let fill = isEnabled
            ? (configuration.isPressed ? enabledColor.opacity(0.85) : enabledColor)
            : disabledColor
            
            configuration.label
                .frame(maxWidth: .infinity)
                .frame(height: 52)                       // ← размер только здесь
                .background(RoundedRectangle(cornerRadius: 12).fill(fill))
                .foregroundStyle(.white.opacity(isEnabled ? 1 : 0.7))
                .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
                .animation(.easeOut(duration: 0.15), value: isEnabled)
        }
    }
}
    

