//
//  TabBarRootView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//

import SwiftUI


struct TabBarRootView: View {
    @State private var selection: AppTab = .home
    @StateObject private var viewModel = TabBarViewModel()

    var body: some View {
        ZStack {
            Group {
                switch selection {
                case .home:
                    HomeView()
                case .translator:
                    TranslatorView()
                case .chat:
                    ChatView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                CustomTabBar(selection: $selection) {
                    // onCenterTap
                }
            }
        }
        .onAppear(perform: {
            viewModel.loadUserInfo()
        })
        .environmentObject(viewModel)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    TabBarRootView()
}
