//
//  ToastContainer.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import SwiftUI

struct ToastContainer: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            ToastView()
                .ignoresSafeArea()
                .padding(.top, 12)
        }
    }
}

extension View {
    func withToasts() -> some View { modifier(ToastContainer()) }
}
