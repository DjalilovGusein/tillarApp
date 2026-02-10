//
//  TopRoundSHape.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//

import SwiftUI

struct TopRoundedRectangle: Shape {
    var radius: CGFloat = 22

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
