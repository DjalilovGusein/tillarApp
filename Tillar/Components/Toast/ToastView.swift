//
//  ToastView.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import SwiftUI

struct ToastView: View {
    @ObservedObject var toast = ToastService.shared

    var body: some View {
        if toast.isVisible, let message = toast.message {
            VStack {
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.primaryText)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.top, 20)
                Spacer()
            }
            .animation(.spring(), value: toast.isVisible)
        }
    }
}

#Preview {
    ToastView()
}
