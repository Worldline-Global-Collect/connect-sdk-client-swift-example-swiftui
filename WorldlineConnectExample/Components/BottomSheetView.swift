//
//  BottomSheet.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

enum BottomSheetHeaderType {
    case title(String)
    case handle
}

struct BottomSheetView<Content: View>: View {

    private var dragToDismissThreshold: CGFloat { height * 0.2 }
    private var grayBackgroundOpacity: Double { isPresented ? (0.4 - Double(draggedOffset)/600) : 0 }

    @State private var draggedOffset: CGFloat = 0
    @State private var previousDragValue: DragGesture.Value?

    @Binding var isPresented: Bool
    private let height: CGFloat
    private let topBarHeight: CGFloat
    private let topBarCornerRadius: CGFloat
    private let content: Content
    private let contentBackgroundColor: Color
    private let topBarBackgroundColor: Color
    private let showTopIndicator: Bool
    private let headerType: BottomSheetHeaderType

    init(
        isPresented: Binding<Bool>,
        height: CGFloat,
        headerType: BottomSheetHeaderType = .handle,
        topBarHeight: CGFloat = 30,
        topBarCornerRadius: CGFloat? = nil,
        topBarBackgroundColor: Color = Color(.systemBackground),
        contentBackgroundColor: Color = Color(.systemBackground),
        showTopIndicator: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.topBarBackgroundColor = topBarBackgroundColor
        self.headerType = headerType
        self.contentBackgroundColor = contentBackgroundColor
        self._isPresented = isPresented
        self.height = height
        self.topBarHeight = topBarHeight
        if let topBarCornerRadius = topBarCornerRadius {
            self.topBarCornerRadius = topBarCornerRadius
        } else {
            self.topBarCornerRadius = topBarHeight / 3
        }
        self.showTopIndicator = showTopIndicator
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.fullScreenLightGrayOverlay()
                VStack(spacing: 0) {
                    self.topBar(headerType: self.headerType, geometry: geometry)
                    VStack(spacing: -8) {
                        Spacer()
                        self.content.padding(.bottom, geometry.safeAreaInsets.bottom)
                        Spacer()
                    }
                }
                .frame(height: self.height - min(self.draggedOffset*2, 0))
                .background(self.contentBackgroundColor)
                .cornerRadius(self.topBarCornerRadius, corners: [.topLeft, .topRight])
                .animation(.interactiveSpring())
                .offset(y:
                    self.isPresented ?
                    (geometry.size.height/2 - self.height/2 + geometry.safeAreaInsets.bottom + self.draggedOffset) :
                    (geometry.size.height/2 + self.height/2 + geometry.safeAreaInsets.bottom)
                )
            }
        }
    }

    fileprivate func fullScreenLightGrayOverlay() -> some View {
        Color
            .black
            .opacity(grayBackgroundOpacity)
            .edgesIgnoringSafeArea(.all)
            .animation(.interactiveSpring())
            .onTapGesture { self.isPresented = false }
    }

    @ViewBuilder
    fileprivate func topBar(headerType: BottomSheetHeaderType, geometry: GeometryProxy) -> some View {
        ZStack {
            switch headerType {
            case .title(let title):
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("grey1"))
                        .font(.system(size: 26))
                        .opacity(0)
                    Spacer()
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.darkGray))
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.lightGray))
                        .font(.system(size: 26))
                        .onTapGesture {
                            self.isPresented = false
                        }
                }
                .padding(.horizontal)
                .padding(.top)
                .opacity(showTopIndicator ? 1 : 0)
            case .handle:
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(UIColor.lightGray))
                    .frame(width: 60, height: 6)
                    .opacity(showTopIndicator ? 1 : 0)
            }
        }
        .frame(width: geometry.size.width, height: topBarHeight)
        .background(topBarBackgroundColor)
        .gesture(
            DragGesture()
                .onChanged({ (value) in

                    let offsetY = value.translation.height
                    self.draggedOffset = offsetY

                    if let previousValue = self.previousDragValue {
                        let previousOffsetY = previousValue.translation.height
                        let timeDiff = Double(value.time.timeIntervalSince(previousValue.time))
                        let heightDiff = Double(offsetY - previousOffsetY)
                        let velocityY = heightDiff / timeDiff
                        if velocityY > 1400 {
                            self.isPresented = false
                            return
                        }
                    }
                    self.previousDragValue = value

                })
                .onEnded({ (value) in
                    let offsetY = value.translation.height
                    if offsetY > self.dragToDismissThreshold {
                        self.isPresented = false
                    }
                    self.draggedOffset = 0
                })
        )
    }
}
