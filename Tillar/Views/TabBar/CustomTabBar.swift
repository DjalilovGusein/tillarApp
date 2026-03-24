//
//  CustomTabBar.swift
//  Tillar
//
//  Created by Gusein Djalilov on 06/01/26.
//

import SwiftUI
import Foundation

struct CustomTabBar: View {
    @Binding var selection: AppTab
    var onCenterTap: () -> Void = {}

    private let barHeight: CGFloat = 64
    private let cornerRadius: CGFloat = 22
    private let notchRadius: CGFloat = 28
    private let centerButtonSize: CGFloat = 56

    var body: some View {
        GeometryReader { geo in
            let bottomInset = geo.safeAreaInsets.bottom

            ZStack(alignment: .top) {

                // Background with notch
                NotchedTabBarShape(
                    cornerRadius: cornerRadius,
                    notchRadius: notchRadius
                )
                .fill(.tabBarBackground)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -2)
                .frame(height: barHeight + bottomInset)   // ✅ закрываем safe area
                .overlay(
                    HStack(spacing: 0) {
                        tabButton(.home)
                        tabButton(.translator)

                        Spacer(minLength: centerButtonSize)

                        tabButton(.chat)
                        tabButton(.profile)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 10)
                    .padding(.bottom, max(12, bottomInset)) // ✅ чтобы кнопки не упирались в home indicator
                )

                // Floating center button
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        onCenterTap()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.tabBarBackground)
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)

                      /*  Circle()
                            .stroke(Color.white, lineWidth: 2) */

                        Image( "aiBar")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.primaryIcon)
                    }
                    .frame(width: centerButtonSize, height: centerButtonSize)
                }
                .buttonStyle(.plain)
                .offset(y: -(centerButtonSize / 2) - 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(edges: .bottom)   // ✅ критично
        }
        .frame(height: barHeight + 34) // можно оставить, можно убрать
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = (selection == tab)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 6) {
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isSelected ? Color.tabBarAccent : Color.gray.opacity(0.6))

                Text(tab.title)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.tabBarAccent : Color.gray.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shape (rounded bar + top notch)

private struct NotchedTabBarShape: Shape {
    var cornerRadius: CGFloat
    var notchRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        let r = cornerRadius
        let nr = notchRadius

        let centerX = w / 2
        let notchCenterY: CGFloat = 0 // вырез в верхней границе

        // Точки начала/конца выреза по X
        let notchStartX = centerX - nr - 10
        let notchEndX   = centerX + nr + 10

        var p = Path()

        // Start: left top (after corner)
        p.move(to: CGPoint(x: r, y: 0))

        // Top-left corner
        p.addArc(
            center: CGPoint(x: r, y: r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(180),
            clockwise: true
        )

        // Left side down
        p.addLine(to: CGPoint(x: 0, y: h - r))

        // Bottom-left corner
        p.addArc(
            center: CGPoint(x: r, y: h - r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )

        // Bottom line
        p.addLine(to: CGPoint(x: w - r, y: h))

        // Bottom-right corner
        p.addArc(
            center: CGPoint(x: w - r, y: h - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )

        // Right side up
        p.addLine(to: CGPoint(x: w, y: r))

        // Top-right corner
        p.addArc(
            center: CGPoint(x: w - r, y: r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(-90),
            clockwise: true
        )

        // Top line до выреза справа
        p.addLine(to: CGPoint(x: notchEndX, y: 0))

        // Вырез (вогнутая дуга)
        p.addQuadCurve(
            to: CGPoint(x: notchStartX, y: 0),
            control: CGPoint(x: centerX, y: notchCenterY + nr + 16)
        )

        // Закрываем верхнюю линию до старта
        p.addLine(to: CGPoint(x: r, y: 0))

        p.closeSubpath()
        return p
    }
}
