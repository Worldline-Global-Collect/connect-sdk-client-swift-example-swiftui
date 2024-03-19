//
//  View+Extensions.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path =
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
        return Path(path.cgPath)
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        headerType: BottomSheetHeaderType,
        height: CGFloat,
        topBarHeight: CGFloat = 30,
        topBarCornerRadius: CGFloat? = nil,
        contentBackgroundColor: Color = Color(.systemBackground),
        topBarBackgroundColor: Color = Color(.systemBackground),
        showTopIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            BottomSheetView(isPresented: isPresented,
                        height: height,
                        headerType: headerType,
                        topBarHeight: topBarHeight,
                        topBarCornerRadius: topBarCornerRadius,
                        topBarBackgroundColor: topBarBackgroundColor,
                        contentBackgroundColor: contentBackgroundColor,
                        showTopIndicator: showTopIndicator,
                        content: content)
        }
    }
}
