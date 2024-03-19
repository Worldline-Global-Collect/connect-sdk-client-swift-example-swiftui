//
//  EndScreen.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import WorldlineConnectKit
import SwiftUI

struct EndScreen: View {

    // MARK: - State
    @ObservedObject var viewModel: ViewModel

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("SuccessLabel".localized)
                    .font(.largeTitle)
                Text("SuccessText".localized)
                    .font(.headline)
                Button(
                    viewModel.showEncryptedFields ?
                    "EncryptedDataResultHide".localized :
                    "EncryptedDataResultShow".localized
                ) {
                    viewModel.showEncryptedFields.toggle()
                }

                if viewModel.showEncryptedFields {
                    VStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("EncryptedFieldsHeader".localized)
                                .bold()
                            Text(viewModel.preparedPaymentRequest?.encryptedFields ?? "")
                        }
                        VStack(alignment: .leading) {
                            Text("EncryptedClientMetaInfoHeader".localized)
                                .bold()
                            Text(viewModel.preparedPaymentRequest?.encodedClientMetaInfo ?? "")
                        }
                    }
                }

                Button(action: {
                    viewModel.copyToClipboard()
                }, label: {
                    Text("CopyEncryptedDataLabel".localized)
                        .foregroundColor(.green)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.green, lineWidth: 2)
                        )
                })

                Button(action: {
                    viewModel.returnToStart()
                }, label: {
                    Text("ReturnToStart".localized)
                        .foregroundColor(.red)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 2)
                        )
                })
            }
            .padding()
        }
    }
}

// MARK: - Previews
#Preview {
    EndScreen(viewModel: EndScreen.ViewModel(preparedPaymentRequest: nil))
}
