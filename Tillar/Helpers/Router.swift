//
//  Router.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/10/25.
//

import SwiftUI

@MainActor
final class Router<Route: Hashable>: ObservableObject {
    @Published var path: [Route] = []

    func push(_ route: Route) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func popToRoot() { path.removeAll() }
}

enum AppRoute: Hashable {
    case signIn
    case createAccount
    case forgotPassword
    case resetPassword
}

struct NavigationHost<Route: Hashable, Root: View, Destination: View>: View {
    @StateObject private var router = Router<Route>()
    private let root: () -> Root
    private let destination: (Route) -> Destination
    
    init(
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.root = root
        self.destination = destination
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: Route.self, destination: destination)
        }
        .environmentObject(router)
    }
}

struct AppRootView: View {
    var body: some View {
        NavigationHost {
            TabBarRootView()
        } destination: { (route: AppRoute) in
            switch route {
            case .signIn:
                SignInView()
            case .createAccount:
                CreateAccountView()
            case .forgotPassword:
                ForgotPasswordView()
            case .resetPassword:
                ResetPasswordView()
            }
        }
    }
}



extension View {
    func previewWithRouter<R: Hashable>(_ route: R.Type = R.self) -> some View {
        self.environmentObject(Router<R>())
    }
}
