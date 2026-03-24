//
//  TillarApp.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/10/25.
//

import SwiftUI

@main
struct TillarApp: App {
    @AppStorage("tillar_theme") private var themeRaw: String = AppTheme.light.rawValue
    private var theme: AppTheme { AppTheme(rawValue: themeRaw) ?? .light }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(theme == .dark ? .dark : .light)
        }
    }
}
