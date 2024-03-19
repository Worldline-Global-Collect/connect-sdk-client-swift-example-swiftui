//
//  ActivityIndicator.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
