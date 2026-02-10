//
//  LoaderView.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import SwiftUI

struct LoaderView: View {
    @ObservedObject private var loader = LoaderService.shared

    var body: some View {
        Group {
            if loader.isLoading {
                ZStack {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .tint(Color.accentIcon)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: loader.isLoading)
            }
        }
        .allowsHitTesting(loader.isLoading)
    }
}

#Preview {
    LoaderView()
}
