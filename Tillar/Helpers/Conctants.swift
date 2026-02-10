//
//  Conctants.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//
import Foundation
import SwiftUI

let UD = UserDefaults(suiteName: "group.uz.tillar.tillar")!


struct HideKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded { hideKeyboard() }
            )
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(HideKeyboardOnTapModifier())
    }
}

#if canImport(UIKit)
private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
}
#endif
