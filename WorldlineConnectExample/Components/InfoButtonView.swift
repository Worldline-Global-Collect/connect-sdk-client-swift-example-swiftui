//
//  InfoButtonView.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 05/05/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct InfoButtonView: View {

    // MARK: - Properties
    var buttonCallback: (() -> Void)?

    // MARK: - Body
    var body: some View {
        Image(systemName: "info.circle")
            .padding(.trailing, 20)
            .onTapGesture {
                if let buttonCallback = buttonCallback {
                    buttonCallback()
                }
            }
    }
}

// MARK: - Previews
#Preview {
    InfoButtonView()
}
