//
//  LoaderContainer.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 09/10/25.
//

import SwiftUI

struct LoaderContainer: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            LoaderView()
        }
    }
}

extension View {
    func withLoader() -> some View {
        modifier(LoaderContainer())
    }
}
