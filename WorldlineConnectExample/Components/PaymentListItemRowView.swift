//
//  PaymentListItemCellView.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 05/05/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct PaymentListItemRowView: View {
    // MARK: - Properties
    var image: UIImage
    var text: String

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(12)
            PaymentListItemView(image: image, text: text)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Previews
#Preview {
    List {
        ForEach(0...5, id: \.self ) { _ in
            PaymentListItemRowView(image: UIImage(), text: "Example text")
        }
    }
}
