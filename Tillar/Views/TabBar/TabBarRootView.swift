import SwiftUI

struct TabBarRootView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {

            Group {
                switch selection {
                case .home:
                    HomeView()
                case .courses:
                    CoursesView()
                case .progress:
                    ProgressViewScreen()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selection: $selection)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    TabBarRootView()
}
